using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;
using Web_CuaHangCafe.Data;
using Web_CuaHangCafe.Models;
using Web_CuaHangCafe.Models.Authentication;
using X.PagedList;

namespace Web_CuaHangCafe.Areas.Admin.Controllers
{
    [Area("Admin")]
    [Route("Admin/Accounts")]
    public class AccountsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public AccountsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Hàm băm mật khẩu dùng SHA-256
        public static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                // Chuyển chuỗi password thành mảng byte
                byte[] passwordBytes = Encoding.UTF8.GetBytes(password);

                // Tính toán băm SHA-256 cho mảng byte password
                byte[] hashBytes = sha256.ComputeHash(passwordBytes);

                // Chuyển mảng byte thành chuỗi hex
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    builder.Append(hashBytes[i].ToString("x2"));
                }

                return builder.ToString();
            }
        }

        [Route("")]
        [Route("Index")]
        [Authentication]  // Comment hoặc xóa nếu không cần kiểm tra đăng nhập
        public IActionResult Index(int? page)
        {
            int pageSize = 30;
            int pageNumber = (page == null || page < 0) ? 1 : page.Value;

            // Lấy danh sách tài khoản theo tên
            var listItem = _context.TbTaiKhoans
                                   .AsNoTracking()
                                   .OrderBy(x => x.TenTaiKhoan)
                                   .ToList();

            // Sử dụng PagedList với kiểu dữ liệu TbTaiKhoan
            PagedList<TbTaiKhoan> pagedListItem = new PagedList<TbTaiKhoan>(listItem, pageNumber, pageSize);

            return View(pagedListItem);
        }

        [Route("Create")]
        [Authentication]
        [HttpGet]
        public IActionResult Create()
        {
            // Nạp danh sách nhân viên
            ViewBag.MaNhanVien = new SelectList(_context.TbNhanViens.ToList(), "MaNhanVien", "HoTen");
            // Nạp danh sách quyền
            ViewBag.MaQuyen = new SelectList(_context.TbQuyens.ToList(), "MaQuyen", "TenQuyen");

            return View();
        }
        [Route("Create")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(TbTaiKhoan taiKhoan)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.MaNhanVien = new SelectList(_context.TbNhanViens.ToList(), "MaNhanVien", "HoTen");
                ViewBag.MaQuyen = new SelectList(_context.TbQuyens.ToList(), "MaQuyen", "TenQuyen");
                return View(taiKhoan);
            }

            if (!string.IsNullOrWhiteSpace(taiKhoan.MatKhau))
            {
                taiKhoan.MatKhau = HashPassword(taiKhoan.MatKhau.Trim());
            }

            // Truy xuất đối tượng từ database trước khi gán vào navigation properties
            var nhanVien = _context.TbNhanViens.Find(taiKhoan.MaNhanVien);
            var quyen = _context.TbQuyens.Find(taiKhoan.MaQuyen);

            if (nhanVien == null || quyen == null)
            {
                ModelState.AddModelError("", "Nhân viên hoặc quyền không hợp lệ.");
                ViewBag.MaNhanVien = new SelectList(_context.TbNhanViens.ToList(), "MaNhanVien", "HoTen");
                ViewBag.MaQuyen = new SelectList(_context.TbQuyens.ToList(), "MaQuyen", "TenQuyen");
                return View(taiKhoan);
            }

            taiKhoan.MaNhanVienNavigation = nhanVien;
            taiKhoan.MaQuyenNavigation = quyen;

            _context.TbTaiKhoans.Add(taiKhoan);
            _context.SaveChanges();
            TempData["Message"] = "Thêm tài khoản thành công";

            return RedirectToAction("Index", "Accounts");
        }




        [Route("Edit")]
        [Authentication]
        [HttpGet]
        public IActionResult Edit(int id, string name)
        {
            // Lấy tài khoản cần sửa
            var taiKhoan = _context.TbTaiKhoans.Find(id);
            ViewBag.id = id;
            return View(taiKhoan);
        }

        [Route("Edit")]
        [Authentication]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(TbTaiKhoan taiKhoan)
        {
            // Mã hóa lại mật khẩu trước khi lưu
            string hashPass = HashPassword(taiKhoan.MatKhau);
            taiKhoan.MatKhau = hashPass;

            _context.Entry(taiKhoan).State = EntityState.Modified;
            _context.SaveChanges();

            TempData["Message"] = "Sửa thành công";

            return RedirectToAction("Index", "Accounts");
        }

        [Route("Delete")]
        [Authentication]
        [HttpGet]
        public IActionResult Delete(int id)
        {
            TempData["Message"] = "";
            var taiKhoan = _context.TbTaiKhoans.Find(id);
            if (taiKhoan != null)
            {
                _context.TbTaiKhoans.Remove(taiKhoan);
                _context.SaveChanges();
                TempData["Message"] = "Xoá thành công";
            }
            else
            {
                TempData["Message"] = "Không tìm thấy tài khoản cần xoá";
            }

            return RedirectToAction("Index", "Accounts");
        }
    }
}