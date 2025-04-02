using System;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Web_CuaHangCafe.Data;
using Web_CuaHangCafe.Models;
using Web_CuaHangCafe.Models.Authentication;
using X.PagedList;

namespace Web_CuaHangCafe.Areas.Admin.Controllers
{
    [Area("Admin")]
    [Route("Admin/NhanViens")]
    public class NhanViensController : Controller
    {
        private readonly ApplicationDbContext _context;

        public NhanViensController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Danh sách nhân viên với phân trang
        [Route("")]
        [Route("Index")]
        [Authentication]
        public IActionResult Index(int? page)
        {
            int pageSize = 30;
            int pageNumber = page == null || page < 0 ? 1 : page.Value;
            var listEmployee = _context.TbNhanViens.AsNoTracking()
                                  .OrderBy(x => x.HoTen)
                                  .ToList();
            PagedList<TbNhanVien> pagedList = new PagedList<TbNhanVien>(listEmployee, pageNumber, pageSize);
            return View(pagedList);
        }

        // Tìm kiếm nhân viên theo tên hoặc số điện thoại
        [Route("Search")]
        [Authentication]
        [HttpGet]
        public IActionResult Search(int? page, string search)
        {
            int pageSize = 30;
            int pageNumber = page == null || page < 0 ? 1 : page.Value;

            if (string.IsNullOrWhiteSpace(search))
            {
                return RedirectToAction("Index");
            }
            search = search.ToLower();
            ViewBag.search = search;

            var results = _context.TbNhanViens.AsNoTracking()
                             .Where(x => x.HoTen.ToLower().Contains(search) || (x.Sdt != null && x.Sdt.ToLower().Contains(search)))
                             .OrderBy(x => x.HoTen)
                             .ToList();
            var pagedList = new PagedList<TbNhanVien>(results, pageNumber, pageSize);
            return View(pagedList);
        }

        // Xem chi tiết nhân viên (bao gồm thông tin, tài khoản, phiếu nhập hàng)
        [Route("Details/{id}")]
        [Authentication]
        [HttpGet]
        public IActionResult Details(int id)
        {
            var employee = _context.TbNhanViens
                                .Include(x => x.TbTaiKhoans)
                                .Include(x => x.TbPhieuNhapHangs)
                                    .ThenInclude(ph => ph.TbPhieuNhapChiTiets)
                                .FirstOrDefault(x => x.MaNhanVien == id);

            if (employee == null)
            {
                TempData["Message"] = "Không tìm thấy nhân viên.";
                return RedirectToAction("Index", "NhanViens");
            }
            return View(employee);
        }

        // Tạo nhân viên mới (nếu cần: ngoài chức năng đăng ký tự động cho nhân viên)
        [Route("Create")]
        [Authentication]
        [HttpGet]
        public IActionResult Create()
        {
            return View();
        }

        [Route("Create")]
        [Authentication]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(TbNhanVien nhanVien)
        {
            if (ModelState.IsValid)
            {
                _context.TbNhanViens.Add(nhanVien);
                _context.SaveChanges();
                TempData["Message"] = "Thêm nhân viên thành công.";
                return RedirectToAction("Index", "NhanViens");
            }
            return View(nhanVien);
        }

        // Chỉnh sửa thông tin nhân viên
        [Route("Edit")]
        [Authentication]
        [HttpGet]
        public IActionResult Edit(int id)
        {
            var nhanVien = _context.TbNhanViens.Find(id);
            if (nhanVien == null)
            {
                TempData["Message"] = "Không tìm thấy nhân viên cần sửa.";
                return RedirectToAction("Index", "NhanViens");
            }
            return View(nhanVien);
        }

        [Route("Edit")]
        [Authentication]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(TbNhanVien nhanVien)
        {
            if (ModelState.IsValid)
            {
                _context.Entry(nhanVien).State = EntityState.Modified;
                _context.SaveChanges();
                TempData["Message"] = "Cập nhật nhân viên thành công.";
                return RedirectToAction("Index", "NhanViens");
            }
            return View(nhanVien);
        }

        // Xoá nhân viên (với xác nhận và xoá cascade các thông tin liên quan: tài khoản, phiếu nhập hàng – bao gồm chi tiết phiếu nhập)
        [Route("Delete")]
        [Authentication]
        [HttpGet]
        public IActionResult Delete(string id)
        {
            TempData["Message"] = "";
            if (!int.TryParse(id, out int employeeId))
            {
                TempData["Message"] = "Sai định dạng mã nhân viên.";
                return RedirectToAction("Index", "NhanViens");
            }

            var employee = _context.TbNhanViens
                              .Include(x => x.TbTaiKhoans)
                              .Include(x => x.TbPhieuNhapHangs)
                                  .ThenInclude(ph => ph.TbPhieuNhapChiTiets)
                              .FirstOrDefault(x => x.MaNhanVien == employeeId);

            if (employee == null)
            {
                TempData["Message"] = "Không tìm thấy nhân viên cần xóa.";
                return RedirectToAction("Index", "NhanViens");
            }
            return View(employee);
        }

        [Route("Delete")]
        [Authentication]
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public IActionResult DeleteConfirmed(int id)
        {
            var employee = _context.TbNhanViens
                              .Include(x => x.TbTaiKhoans)
                              .Include(x => x.TbPhieuNhapHangs)
                                  .ThenInclude(ph => ph.TbPhieuNhapChiTiets)
                              .FirstOrDefault(x => x.MaNhanVien == id);

            if (employee == null)
            {
                TempData["Message"] = "Không tìm thấy nhân viên cần xóa.";
                return RedirectToAction("Index", "NhanViens");
            }

            // Xoá tài khoản
            foreach (var account in employee.TbTaiKhoans.ToList())
            {
                _context.TbTaiKhoans.Remove(account);
            }

            // Xoá phiếu nhập hàng và chi tiết
            foreach (var phieuNhap in employee.TbPhieuNhapHangs.ToList())
            {
                foreach (var ct in phieuNhap.TbPhieuNhapChiTiets.ToList())
                {
                    _context.TbPhieuNhapChiTiets.Remove(ct);
                }
                _context.TbPhieuNhapHangs.Remove(phieuNhap);
            }

            // Cuối cùng xoá nhân viên
            _context.TbNhanViens.Remove(employee);
            _context.SaveChanges();

            TempData["Message"] = "Xóa nhân viên thành công.";
            return RedirectToAction("Index", "NhanViens");
        }
    }
}
