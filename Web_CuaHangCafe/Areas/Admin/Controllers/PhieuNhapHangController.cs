using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Web_CuaHangCafe.Data;
using Web_CuaHangCafe.Models;
using Web_CuaHangCafe.Models.Authentication;
using X.PagedList;

namespace Web_CuaHangCafe.Areas.Admin.Controllers
{
    [Area("Admin")]
    [Route("Admin/PhieuNhapHang")]
    public class PhieuNhapHangController : Controller
    {
        private readonly ApplicationDbContext _context;

        public PhieuNhapHangController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Admin/PhieuNhapHang
        [Route("")]
        [Route("Index")]
        [Authentication]
        public async Task<IActionResult> Index(int? page)
        {
            int pageSize = 30;
            int pageNumber = (page == null || page < 0) ? 1 : page.Value;

            var listItem = await _context.TbPhieuNhapHangs
                .Include(p => p.MaQuanNavigation)
                .Include(p => p.MaNhanVienNavigation)
                .Include(p => p.MaNhaCungCapNavigation)
                .AsNoTracking()
                .OrderByDescending(p => p.NgayLap)
                .ToListAsync();
            var pagedList = new PagedList<TbPhieuNhapHang>(listItem, pageNumber, pageSize);

            return View(pagedList);
        }

        // GET: Admin/PhieuNhapHang/Search?search=...
        [Route("Search")]
        [Authentication]
        [HttpGet]
        public IActionResult Search(int? page, string search)
        {
            int pageSize = 30;
            int pageNumber = (page == null || page < 0) ? 1 : page.Value;

            // Nếu search có thể chuyển thành ngày, tìm theo ngày lập
            List<TbPhieuNhapHang> listItem;
            if (!string.IsNullOrEmpty(search) && DateTime.TryParse(search, out DateTime searchDate))
            {
                listItem = _context.TbPhieuNhapHangs
                    .AsNoTracking()
                    .Where(p => p.NgayLap.Date == searchDate.Date)
                    .OrderByDescending(p => p.NgayLap)
                    .ToList();
            }
            else
            {
                // Nếu không có giá trị tìm kiếm hợp lệ, trả về tất cả
                listItem = _context.TbPhieuNhapHangs
                    .AsNoTracking()
                    .OrderByDescending(p => p.NgayLap)
                    .ToList();
            }

            var pagedList = new PagedList<TbPhieuNhapHang>(listItem, pageNumber, pageSize);
            ViewBag.search = search;
            return View(pagedList);
        }

        // GET: Admin/PhieuNhapHang/Details/{id}
        [Route("Details/{id}")]
        [Authentication]
        [HttpGet]
        public async Task<IActionResult> Details(Guid? id, int? page)
        {
            if (id == null)
            {
                TempData["Message"] = "Mã phiếu nhập không hợp lệ.";
                return RedirectToAction("Index");
            }
            int pageSize = 30;
            int pageNumber = (page == null || page < 0) ? 1 : page.Value;

            // Include các Chi tiết và thông tin navigation (Nguyên liệu,…)
            var phieuNhap = await _context.TbPhieuNhapHangs
                .Include(p => p.MaQuanNavigation)
                .Include(p => p.MaNhanVienNavigation)
                .Include(p => p.MaNhaCungCapNavigation)
                .Include(p => p.TbPhieuNhapChiTiets)
                    .ThenInclude(ct => ct.MaNguyenLieuNavigation)
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.MaPhieuNhap == id);

            if (phieuNhap == null)
            {
                TempData["Message"] = "Không tìm thấy phiếu nhập.";
                return RedirectToAction("Index");
            }
            return View(phieuNhap);
        }

        // GET: Admin/PhieuNhapHang/Create
        [Route("Create")]
        [Authentication]
        [HttpGet]
        public IActionResult Create()
        {
            var model = new TbPhieuNhapHang
            {
                NgayLap = DateTime.Now
            };

            ViewData["MaQuan"] = new SelectList(_context.TbQuanCafes, "MaQuan", "TenQuan");
            ViewData["MaNhanVien"] = new SelectList(_context.TbNhanViens, "MaNhanVien", "HoTen");
            ViewData["MaNhaCungCap"] = new SelectList(_context.TbNhaCungCaps, "MaNhaCungCap", "TenNhaCungCap");

            return View(model);
        }

        // POST: Admin/PhieuNhapHang/Create
        [Route("Create")]
        [Authentication]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("MaQuan,NgayLap,MaNhanVien,MaNhaCungCap,GhiChu")] TbPhieuNhapHang phieuNhap)
        {
            if (ModelState.IsValid)
            {
                phieuNhap.MaPhieuNhap = Guid.NewGuid();
                _context.TbPhieuNhapHangs.Add(phieuNhap);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["MaQuan"] = new SelectList(_context.TbQuanCafes, "MaQuan", "TenQuan", phieuNhap.MaQuan);
            ViewData["MaNhanVien"] = new SelectList(_context.TbNhanViens, "MaNhanVien", "HoTen", phieuNhap.MaNhanVien);
            ViewData["MaNhaCungCap"] = new SelectList(_context.TbNhaCungCaps, "MaNhaCungCap", "TenNhaCungCap", phieuNhap.MaNhaCungCap);
            return View(phieuNhap);
        }

        // GET: Admin/PhieuNhapHang/Edit/{id}
        [Route("Edit/{id}")]
        [Authentication]
        [HttpGet]
        public async Task<IActionResult> Edit(Guid? id)
        {
            if (id == null)
                return NotFound();
            var phieuNhap = await _context.TbPhieuNhapHangs.FindAsync(id);
            if (phieuNhap == null)
                return NotFound();
            ViewData["MaQuan"] = new SelectList(_context.TbQuanCafes, "MaQuan", "TenQuan", phieuNhap.MaQuan);
            ViewData["MaNhanVien"] = new SelectList(_context.TbNhanViens, "MaNhanVien", "HoTen", phieuNhap.MaNhanVien);
            ViewData["MaNhaCungCap"] = new SelectList(_context.TbNhaCungCaps, "MaNhaCungCap", "TenNhaCungCap", phieuNhap.MaNhaCungCap);
            return View(phieuNhap);
        }

        // POST: Admin/PhieuNhapHang/Edit/{id}
        [Route("Edit/{id}")]
        [Authentication]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Guid id, [Bind("MaPhieuNhap,MaQuan,NgayLap,MaNhanVien,MaNhaCungCap,GhiChu")] TbPhieuNhapHang phieuNhap)
        {
            if (id != phieuNhap.MaPhieuNhap)
                return NotFound();

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(phieuNhap);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!PhieuNhapExists(phieuNhap.MaPhieuNhap))
                        return NotFound();
                    else
                        throw;
                }
                return RedirectToAction(nameof(Index));
            }
            ViewData["MaQuan"] = new SelectList(_context.TbQuanCafes, "MaQuan", "TenQuan", phieuNhap.MaQuan);
            ViewData["MaNhanVien"] = new SelectList(_context.TbNhanViens, "MaNhanVien", "HoTen", phieuNhap.MaNhanVien);
            ViewData["MaNhaCungCap"] = new SelectList(_context.TbNhaCungCaps, "MaNhaCungCap", "TenNhaCungCap", phieuNhap.MaNhaCungCap);
            return View(phieuNhap);
        }

        // GET: Admin/PhieuNhapHang/Delete/{id}
        [Route("Delete/{id}")]
        [Authentication]
        [HttpGet]
        public async Task<IActionResult> Delete(Guid? id)
        {
            if (id == null)
                return NotFound();

            var phieuNhap = await _context.TbPhieuNhapHangs
                .Include(p => p.MaQuanNavigation)
                .Include(p => p.MaNhanVienNavigation)
                .Include(p => p.MaNhaCungCapNavigation)
                .FirstOrDefaultAsync(p => p.MaPhieuNhap == id);
            if (phieuNhap == null)
                return NotFound();
            return View(phieuNhap);
        }

        // POST: Admin/PhieuNhapHang/Delete/{id}
        [Route("Delete/{id}")]
        [Authentication]
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(Guid id)
        {
            var phieuNhap = await _context.TbPhieuNhapHangs.FindAsync(id);
            if (phieuNhap != null)
            {
                // Xoá các chi tiết liên quan trước
                var details = _context.TbPhieuNhapChiTiets.Where(ct => ct.MaPhieuNhap == id);
                _context.TbPhieuNhapChiTiets.RemoveRange(details);
                _context.TbPhieuNhapHangs.Remove(phieuNhap);
                await _context.SaveChangesAsync();
            }
            return RedirectToAction(nameof(Index));
        }

        private bool PhieuNhapExists(Guid id)
        {
            return _context.TbPhieuNhapHangs.Any(e => e.MaPhieuNhap == id);
        }
    }
}
