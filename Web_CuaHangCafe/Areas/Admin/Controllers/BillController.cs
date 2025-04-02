using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Web_CuaHangCafe.Data;
using Web_CuaHangCafe.Models;
using Web_CuaHangCafe.Models.Authentication;
using X.PagedList;

namespace Web_CuaHangCafe.Areas.Admin.Controllers
{
    [Area("Admin")]
    [Route("Admin/Bill")]
    public class BillController : Controller
    {
        private readonly Data.ApplicationDbContext _context;

        public BillController(Data.ApplicationDbContext context)
        {
            _context = context;
        }

        [Route("")]
        [Route("Index")]
        [Authentication]
        public IActionResult Index(int? page)
        {
            int pageSize = 30;
            int pageNumber = page == null || page < 0 ? 1 : page.Value;
            var listItem = _context.TbHoaDonBans
                                   .Include(x => x.MaKhachHangNavigation)
                                        .Include(x => x.MaQuanNavigation)// Load thông tin khách hàng
                                   .AsNoTracking()
                                   .OrderByDescending(x => x.NgayLap)
                                   .ToList();
            PagedList<TbHoaDonBan> pagedListItem = new PagedList<TbHoaDonBan>(listItem, pageNumber, pageSize);

            return View(pagedListItem);
        }


        [Route("Search")]
        [Authentication]
        [HttpGet]
        public IActionResult Search(int? page, string search)
        {
            int pageSize = 30;
            int pageNumber = page == null || page < 0 ? 1 : page.Value;

            ViewBag.search = search;

            // Nếu giá trị search không rỗng và có thể chuyển sang DateTime
            List<TbHoaDonBan> listItem;
            if (!string.IsNullOrEmpty(search) && DateTime.TryParse(search, out DateTime searchDate))
            {
                // So sánh ngày bán (chỉ lấy phần Date) với ngày tìm kiếm
                listItem = _context.TbHoaDonBans
                    .AsNoTracking()
                    .Where(x => x.NgayLap.Date == searchDate.Date)
                    .OrderBy(x => x.MaHoaDon)
                    .ToList();
            }
            else
            {
                // Nếu không có giá trị tìm kiếm hoặc search không hợp lệ, trả về danh sách tất cả
                listItem = _context.TbHoaDonBans
                    .AsNoTracking()
                    .OrderBy(x => x.MaHoaDon)
                    .ToList();
            }

            PagedList<TbHoaDonBan> pagedListItem = new PagedList<TbHoaDonBan>(listItem, pageNumber, pageSize);
            return View(pagedListItem);
        }

        [Route("Details")]
        [Authentication]
        [HttpGet]
        public IActionResult Details(int? page, string id, string name)
        {
            if (string.IsNullOrEmpty(id))
            {
                TempData["Message"] = "Mã hóa đơn không hợp lệ.";
                return RedirectToAction("Index");
            }
            if (!Guid.TryParse(id, out Guid billGuid))
            {
                TempData["Message"] = "Sai định dạng mã hóa đơn.";
                return RedirectToAction("Index");
            }

            int pageSize = 30;
            int pageNumber = (page == null || page < 0) ? 1 : page.Value;

            // Đảm bảo Include navigation property của hóa đơn và sản phẩm
            var listItem = _context.TbChiTietHoaDonBans
                .Include(ct => ct.MaHoaDonNavigation)
                .Include(ct => ct.MaSanPhamNavigation)
                .AsNoTracking()
                .Where(x => x.MaHoaDon == billGuid)
                .OrderBy(x => x.MaHoaDon)
                .ToList();

            if (!listItem.Any())
            {
                TempData["Message"] = "Không tìm thấy chi tiết của hóa đơn.";
                return RedirectToAction("Index");
            }

            var pagedListItem = new X.PagedList.PagedList<TbChiTietHoaDonBan>(listItem, pageNumber, pageSize);

            ViewBag.Name = name;

            return View(pagedListItem);
        }


    }
}
