using Microsoft.AspNetCore.Mvc;
using Web_CuaHangCafe.Models;
using Web_CuaHangCafe.Helpers;
using Web_CuaHangCafe.Data;

namespace Web_CuaHangCafe.Controllers
{
    public class CartController : Controller
    {
        private readonly Data.ApplicationDbContext _context;

        public CartController(Data.ApplicationDbContext context)
        {
            _context = context;
        }

        public List<CartItem> Carts
        {
            get
            {
                var data = HttpContext.Session.Get<List<CartItem>>("Cart");

                if (data == null)
                {
                    data = new List<CartItem>();
                }

                return data;
            }
        }

        public IActionResult Index()
        {
            var cartItems = HttpContext.Session.Get<List<CartItem>>("Cart");

            if (cartItems != null && cartItems.Any())
            {
                decimal? tongTien = cartItems.Sum(p => p.DonGia * p.SoLuong);
                string totalCart = tongTien.Value.ToString("n0");
                ViewData["total"] = totalCart;
                return View(Carts);
            }
            else
            {
                ViewData["Message"] = "Không có sản phẩm trong giỏ hàng.";
                ViewData["total"] = "0";
                return View(Carts);
            }
        }

        public IActionResult Add(int id, int quantity)
        {
            var myCart = Carts;
            var item = myCart.SingleOrDefault(p => p.MaSp == id);
            decimal? tongTien = 0;

            if (item == null)
            {
                var hangHoa = _context.TbSanPhams.SingleOrDefault(p => p.MaSanPham == id);

                item = new CartItem
                {
                    MaSp = id,
                    TenSp = hangHoa.TenSanPham,
                    DonGia = hangHoa.GiaBan,
                    SoLuong = quantity,
                    AnhSp = hangHoa.HinhAnh
                };

                myCart.Add(item);
            }
            else
            {
                item.SoLuong += quantity;
            }

            

            HttpContext.Session.Set("Cart", myCart);
            return RedirectToAction("index");
        }

        [HttpPost]
        public IActionResult Update([FromBody] List<UpdateQuantityRequest> updates)
        {
            if (updates == null || !ModelState.IsValid)
            {
                return BadRequest("Invalid request.");
            }

            var cartItems = HttpContext.Session.Get<List<CartItem>>("Cart");

            if (cartItems != null)
            {
                foreach (var update in updates)
                {
                    var cartItemToUpdate = cartItems.Find(item => item.MaSp == update.ProductId);

                    if (cartItemToUpdate != null)
                    {
                        cartItemToUpdate.SoLuong = update.Quantity;
                    }
                }

                HttpContext.Session.Set("Cart", cartItems);

                decimal? totalAmount = 0;
                foreach (var item in cartItems)
                {
                    totalAmount += item.SoLuong * item.DonGia;
                }

                return Json(new { success = true, message = "Số lượng đã được cập nhật.", totalAmount = totalAmount, cartItems = cartItems });
            }

            return BadRequest("Invalid cart.");
        }

        public class UpdateQuantityRequest
        {
            public int ProductId { get; set; }
            public int Quantity { get; set; }
        }

        [HttpPost]
        public IActionResult Remove(int maSp)
        {
            try
            {
                var cartItems = HttpContext.Session.Get<List<CartItem>>("Cart");

                if (cartItems != null)
                {
                    var productToRemove = cartItems.SingleOrDefault(item => item.MaSp == maSp);

                    if (productToRemove != null)
                    {
                        cartItems.Remove(productToRemove);

                        HttpContext.Session.Set("Cart", cartItems);

                        decimal? totalAmount = 0;

                        foreach (var item in cartItems)
                        {
                            totalAmount += item.SoLuong * item.DonGia;
                        }

                        return Json(new { success = true, message = "Đã xoá sản phẩm.", totalAmount = totalAmount, cartItems = cartItems });
                    }
                    else
                    {
                        Console.WriteLine(maSp);
                        return Json(new { success = false, message = "Không có sản phẩm." });
                    }
                }
                else
                {
                    return Json(new { success = false, message = "Giỏ hàng rỗng." });
                }    
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        public IActionResult Checkout()
        {
            var cartItems = HttpContext.Session.Get<List<CartItem>>("Cart");


            if (cartItems != null && cartItems.Any())
            {
                decimal? tongTien = cartItems.Sum(p => p.DonGia * p.SoLuong);
                string totalCart = tongTien.Value.ToString("n0");
                ViewData["total"] = totalCart;
                return View(Carts);
            }
            else
            {
                return RedirectToAction("index", "home"); 
            }
        }

        public IActionResult Confirmation(string customerName, string phoneNumber, string address)
        {
            // Lấy giỏ hàng từ session
            var cartItems = HttpContext.Session.Get<List<CartItem>>("Cart");

            if (cartItems != null && cartItems.Any())
            {
                // Tìm khách hàng theo số điện thoại
                var customer = _context.TbKhachHangs
                    .FirstOrDefault(x => x.SdtkhachHang == phoneNumber);

                if (customer == null)
                {
                    // Nếu chưa có, tạo mới khách hàng
                    var newCustomer = new TbKhachHang
                    {
                        // KHÔNG gán MaKhachHang, vì cột này là Identity (SQL tự sinh)
                        TenKhachHang = customerName,
                        SdtkhachHang = phoneNumber,
                        DiaChi = address
                    };

                    _context.TbKhachHangs.Add(newCustomer);
                    _context.SaveChanges();

                    // Sau SaveChanges, newCustomer.MaKhachHang sẽ có giá trị Identity
                    int newCustomerId = newCustomer.MaKhachHang;

                    // Tạo hóa đơn mới
                    var order = new TbHoaDonBan
                    {
                        MaHoaDon = Guid.NewGuid(),      // MaHoaDon là uniqueidentifier
                        MaQuan = 1,                     // Giá trị minh họa, bạn tự gán
                        NgayLap = DateTime.Now,
                        MaNhanVien = 1,                 // Tùy logic của bạn
                        MaKhachHang = newCustomerId,    // Gán int cho MaKhachHang
                        HinhThucThanhToan = "Tiền mặt", // Hoặc tuỳ logic
                        TongTien = cartItems.Sum(p => p.DonGia * p.SoLuong) ?? 0m,
                        TrangThai = "Hoàn thành",       // Hoặc tuỳ logic
                        TrangThaiThanhToan = true       // Hoặc tuỳ logic
                    };

                    _context.TbHoaDonBans.Add(order);
                    _context.SaveChanges();
                }
                else
                {
                    // Nếu khách hàng đã tồn tại, cập nhật thông tin nếu cần
                    customer.TenKhachHang = customerName;
                    customer.DiaChi = address;
                    _context.SaveChanges();

                    // Tạo hóa đơn mới với khách hàng đã tồn tại
                    var order = new TbHoaDonBan
                    {
                        MaHoaDon = Guid.NewGuid(),
                        MaQuan = 1,
                        NgayLap = DateTime.Now,
                        MaNhanVien = 1,
                        MaKhachHang = customer.MaKhachHang, // Gán int có sẵn
                        HinhThucThanhToan = "Tiền mặt",
                        TongTien = cartItems.Sum(p => p.DonGia * p.SoLuong) ?? 0m,
                        TrangThai = "Hoàn thành",
                        TrangThaiThanhToan = true
                    };

                    _context.TbHoaDonBans.Add(order);
                    _context.SaveChanges();
                }

                // Thêm chi tiết hóa đơn cho từng sản phẩm trong giỏ
                // Lưu ý: MaHoaDon là Guid, so sánh/truyền đúng kiểu
                foreach (var cartItem in cartItems)
                {
                    var orderDetails = new TbChiTietHoaDonBan
                    {
                        MaHoaDon = _context.TbHoaDonBans.OrderByDescending(x => x.NgayLap).First().MaHoaDon,
                        MaSanPham = cartItem.MaSp,
                        DonGia = cartItem.DonGia ?? 0m,   // Nếu cartItem.DonGia là decimal?
                        SoLuong = cartItem.SoLuong,
                        // ThanhTien được tính cột computed (SoLuong * DonGia), 
                        // nên có thể không cần gán
                    };

                    _context.TbChiTietHoaDonBans.Add(orderDetails);
                    _context.SaveChanges();
                }

                // Xóa giỏ hàng khỏi session sau khi hoàn tất
                HttpContext.Session.Remove("Cart");

                return RedirectToAction("success");
            }
            else
            {
                return RedirectToAction("index", "home");
            }
        }




        public IActionResult Success()
        {
            return View();
        }
    }
}
