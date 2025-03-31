using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Web_CuaHangCafe.Data;
using Web_CuaHangCafe.Models;
using Web_CuaHangCafe.ViewModels;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace Web_CuaHangCafe.Controllers
{
    public class AccountController : Controller
    {
        private readonly ApplicationDbContext _context;

        public AccountController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: /Account/ThongTin
        public async Task<IActionResult> ThongTin()
        {
            string tenTaiKhoan = HttpContext.Session.GetString("TenTaiKhoan") ?? "";
            string role = HttpContext.Session.GetString("Role") ?? "";

            if (string.IsNullOrEmpty(tenTaiKhoan) || string.IsNullOrEmpty(role))
            {
                return RedirectToAction("Login1", "Access1");
            }

            var viewModel = new AccountInfoViewModel { Role = role, TenTaiKhoan = tenTaiKhoan };

            if (role == "Admin")
            {
                var tkAdmin = await _context.TbTaiKhoans.FirstOrDefaultAsync(a => a.TenTaiKhoan == tenTaiKhoan);
                if (tkAdmin == null)
                    return NotFound("Tài khoản admin không tồn tại.");
                var nhanVien = await _context.TbNhanViens
                    .Include(nv => nv.MaQuanNavigation)
                    .FirstOrDefaultAsync(nv => nv.MaNhanVien == tkAdmin.MaNhanVien);
                if (nhanVien == null)
                    return NotFound("Thông tin nhân viên không tồn tại.");
                viewModel.NhanVienInfo = nhanVien;
            }
            else if (role == "User")
            {
                var tkKH = await _context.TbTaiKhoanKhs.FirstOrDefaultAsync(a => a.TenTaiKhoan == tenTaiKhoan);
                if (tkKH == null)
                    return NotFound("Tài khoản khách hàng không tồn tại.");
                var khachHang = await _context.TbKhachHangs.FirstOrDefaultAsync(kh => kh.MaKhachHang == tkKH.MaKhachHang);
                if (khachHang == null)
                    return NotFound("Thông tin khách hàng không tồn tại.");
                viewModel.KhachHangInfo = khachHang;
            }

            return View(viewModel);
        }

        // GET: /Account/EditThongTin
        public async Task<IActionResult> EditThongTin()
        {
            // Tương tự như action ThongTin => load dữ liệu hiện tại vào AccountInfoViewModel
            string tenTaiKhoan = HttpContext.Session.GetString("TenTaiKhoan") ?? "";
            string role = HttpContext.Session.GetString("Role") ?? "";

            if (string.IsNullOrEmpty(tenTaiKhoan) || string.IsNullOrEmpty(role))
                return RedirectToAction("Login1", "Access1");

            var viewModel = new AccountInfoViewModel { Role = role, TenTaiKhoan = tenTaiKhoan };

            if (role == "Admin")
            {
                var tkAdmin = await _context.TbTaiKhoans.FirstOrDefaultAsync(a => a.TenTaiKhoan == tenTaiKhoan);
                if (tkAdmin == null)
                    return NotFound("Tài khoản admin không tồn tại.");
                var nhanVien = await _context.TbNhanViens
                    .Include(nv => nv.MaQuanNavigation)
                    .FirstOrDefaultAsync(nv => nv.MaNhanVien == tkAdmin.MaNhanVien);
                if (nhanVien == null)
                    return NotFound("Thông tin nhân viên không tồn tại.");
                viewModel.NhanVienInfo = nhanVien;
            }
            else if (role == "User")
            {
                var tkKH = await _context.TbTaiKhoanKhs.FirstOrDefaultAsync(a => a.TenTaiKhoan == tenTaiKhoan);
                if (tkKH == null)
                    return NotFound("Tài khoản khách hàng không tồn tại.");
                var khachHang = await _context.TbKhachHangs.FirstOrDefaultAsync(kh => kh.MaKhachHang == tkKH.MaKhachHang);
                if (khachHang == null)
                    return NotFound("Thông tin khách hàng không tồn tại.");
                viewModel.KhachHangInfo = khachHang;
            }

            return View(viewModel);
        }

        // POST: /Account/EditThongTin
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditThongTin(AccountInfoViewModel model)
        {
            string tenTaiKhoan = HttpContext.Session.GetString("TenTaiKhoan") ?? "";
            string role = HttpContext.Session.GetString("Role") ?? "";

            if (string.IsNullOrEmpty(tenTaiKhoan) || string.IsNullOrEmpty(role))
                return RedirectToAction("Login1", "Access1");

            if (!ModelState.IsValid)
                return View(model);

            if (role == "Admin")
            {
                var tkAdmin = await _context.TbTaiKhoans.FirstOrDefaultAsync(a => a.TenTaiKhoan == tenTaiKhoan);
                if (tkAdmin == null)
                    return NotFound("Tài khoản admin không tồn tại.");

                var nhanVien = await _context.TbNhanViens.FirstOrDefaultAsync(nv => nv.MaNhanVien == tkAdmin.MaNhanVien);
                if (nhanVien == null)
                    return NotFound("Thông tin nhân viên không tồn tại.");

                // Cập nhật các trường sửa đổi
                nhanVien.HoTen = model.NhanVienInfo?.HoTen ?? nhanVien.HoTen;
                nhanVien.DiaChi = model.NhanVienInfo?.DiaChi ?? nhanVien.DiaChi;
                nhanVien.Email = model.NhanVienInfo?.Email ?? nhanVien.Email;
                // Nếu có thêm trường khác, cập nhật tương tự
            }
            else if (role == "User")
            {
                var tkKH = await _context.TbTaiKhoanKhs.FirstOrDefaultAsync(a => a.TenTaiKhoan == tenTaiKhoan);
                if (tkKH == null)
                    return NotFound("Tài khoản khách hàng không tồn tại.");

                var khachHang = await _context.TbKhachHangs.FirstOrDefaultAsync(kh => kh.MaKhachHang == tkKH.MaKhachHang);
                if (khachHang == null)
                    return NotFound("Thông tin khách hàng không tồn tại.");

                // Cập nhật các thông tin của khách hàng
                khachHang.TenKhachHang = model.KhachHangInfo?.TenKhachHang ?? khachHang.TenKhachHang;
                khachHang.DiaChi = model.KhachHangInfo?.DiaChi ?? khachHang.DiaChi;
                khachHang.SdtkhachHang = model.KhachHangInfo?.SdtkhachHang ?? khachHang.SdtkhachHang;
                // Cập nhật thêm các trường khác nếu có
            }

            try
            {
                await _context.SaveChangesAsync();
                TempData["Message"] = "Cập nhật thông tin thành công!";
                return RedirectToAction("ThongTin");
            }
            catch
            {
                ModelState.AddModelError("", "Có lỗi xảy ra khi cập nhật, vui lòng thử lại.");
                return View(model);
            }
        }
    }
}
