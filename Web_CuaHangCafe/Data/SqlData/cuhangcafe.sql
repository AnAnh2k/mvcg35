-- ==========================================
-- Tạo Database TheSpaceCoffee2
-- ==========================================
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TheSpaceCoffee2')
BEGIN
    DROP DATABASE [TheSpaceCoffee2];
END;
GO

CREATE DATABASE [TheSpaceCoffee2];
GO

USE [TheSpaceCoffee2];
GO

-- ==========================================
-- 1. Bảng tbQuanCafe
-- ==========================================
CREATE TABLE tbQuanCafe (
    MaQuan INT IDENTITY(1,1) PRIMARY KEY,
    TenQuan NVARCHAR(255) NOT NULL,
    DiaChi NVARCHAR(255) NOT NULL,
    SDT VARCHAR(20) NOT NULL UNIQUE,
    Email NVARCHAR(255) NULL UNIQUE
);
GO

-- ==========================================
-- 2. Bảng tbNguyenLieu
-- ==========================================
CREATE TABLE tbNguyenLieu (
    MaNguyenLieu INT IDENTITY(1,1) PRIMARY KEY,
    TenNguyenLieu NVARCHAR(255) NOT NULL,
    SoLuong DECIMAL(10,2) NOT NULL DEFAULT 0,
    DonViTinh NVARCHAR(50) NOT NULL,
    HanSuDung DATE NULL,
    DonGia DECIMAL(10,2) NOT NULL DEFAULT 0,
    SoLuongToiThieu DECIMAL(10,2) NOT NULL DEFAULT 0
);
GO

-- ==========================================
-- 3. Bảng tbNhomSanPham
-- ==========================================
CREATE TABLE tbNhomSanPham (
    MaNhomSP INT IDENTITY(1,1) PRIMARY KEY,
    TenNhomSP NVARCHAR(255) NOT NULL
);
GO

-- ==========================================
-- 4. Bảng tbSanPham (có cột GhiChu)
-- ==========================================
CREATE TABLE tbSanPham (
    MaSanPham INT IDENTITY(1,1) PRIMARY KEY,
    TenSanPham NVARCHAR(255) NOT NULL UNIQUE,
    GiaBan DECIMAL(10,2) NOT NULL CHECK (GiaBan > 0),
    MoTa NVARCHAR(MAX) NULL,
    HinhAnh NVARCHAR(MAX) NULL,
    GhiChu NVARCHAR(MAX) NULL, -- Cột ghi chú
    MaNhomSP INT NOT NULL,
    FOREIGN KEY (MaNhomSP) REFERENCES tbNhomSanPham(MaNhomSP) ON DELETE CASCADE
);
GO

-- ==========================================
-- 5. Bảng tbNhaCungCap
-- (Bảng này vẫn giữ kiểu UNIQUEIDENTIFIER vì không thuộc danh sách cần thay đổi)
-- ==========================================
CREATE TABLE tbNhaCungCap (
    MaNhaCungCap INT IDENTITY(1,1) PRIMARY KEY,
    TenNhaCungCap NVARCHAR(255) NOT NULL,
    DiaChi NVARCHAR(255) NULL,
    SDTNCC VARCHAR(20) NOT NULL UNIQUE,
    STK VARCHAR(50) NULL
);
GO

-- ==========================================
-- 6. Bảng tbNhanVien
-- ==========================================
CREATE TABLE tbNhanVien (
    MaNhanVien INT IDENTITY(1,1) PRIMARY KEY,
    MaQuan INT NOT NULL,
    HoTen NVARCHAR(255) NOT NULL,
    DiaChi NVARCHAR(255) NULL,
    NgaySinh DATE NULL,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN ('Nam','Nữ')),
    ChucVu NVARCHAR(50) NOT NULL,
    SDT VARCHAR(20) NOT NULL UNIQUE,
    SoCCCD VARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(255) NULL UNIQUE,
    LuongCoBan DECIMAL(10,2) NOT NULL DEFAULT 0,
    HeSoLuong DECIMAL(4,2) NOT NULL DEFAULT 1,
    FOREIGN KEY (MaQuan) REFERENCES tbQuanCafe(MaQuan) ON DELETE CASCADE
);
GO

UPDATE tbNhanVien
SET ChucVu = N'Nhân viên'
WHERE ChucVu NOT IN (N'Quản lý', N'Nhân viên');
GO
ALTER TABLE tbNhanVien
ADD CONSTRAINT CHK_ChucVu CHECK (ChucVu IN (N'Quản lý', N'Nhân viên'));
GO




-- ==========================================
-- 7. Bảng tbKhachHang
-- ==========================================
CREATE TABLE tbKhachHang (
    MaKhachHang INT IDENTITY(1,1) PRIMARY KEY,
    TenKhachHang NVARCHAR(255) NOT NULL,
    SDTKhachHang VARCHAR(10) NOT NULL UNIQUE,
    DiaChi NVARCHAR(255) NOT NULL
);
GO

-- ==========================================
-- 8. Bảng tbGioHang
-- ==========================================
CREATE TABLE tbGioHang (
    MaKhachHang INT NOT NULL,
    MaSanPham INT NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong >= 0),
    PRIMARY KEY (MaKhachHang, MaSanPham),
    FOREIGN KEY (MaKhachHang) REFERENCES tbKhachHang(MaKhachHang),
    FOREIGN KEY (MaSanPham) REFERENCES tbSanPham(MaSanPham)
);
GO

-- ==========================================
-- 9. Bảng tbQuyen
-- ==========================================
CREATE TABLE tbQuyen (
    MaQuyen INT IDENTITY(1,1) PRIMARY KEY,
    TenQuyen NVARCHAR(255) NOT NULL UNIQUE
);
GO

-- ==========================================
-- 10. Bảng tbTaiKhoan (Tài khoản nhân viên)
-- ==========================================
CREATE TABLE tbTaiKhoan (
    MaTaiKhoan INT IDENTITY(1,1) PRIMARY KEY,
    TenTaiKhoan NVARCHAR(255) NOT NULL UNIQUE,
    MatKhau NVARCHAR(255) NOT NULL,
    MaNhanVien INT NOT NULL,
    MaQuyen INT NOT NULL,
    FOREIGN KEY (MaNhanVien) REFERENCES tbNhanVien(MaNhanVien) ON DELETE CASCADE,
    FOREIGN KEY (MaQuyen) REFERENCES tbQuyen(MaQuyen) ON DELETE CASCADE
);
GO

-- ==========================================
-- 11. Bảng tbTaiKhoanKH (Tài khoản khách hàng)
-- ==========================================
CREATE TABLE tbTaiKhoanKH (
    MaTaiKhoan INT IDENTITY(1,1) PRIMARY KEY,
    TenTaiKhoan NVARCHAR(255) NOT NULL UNIQUE,
    MatKhau NVARCHAR(255) NOT NULL,
    MaKhachHang INT NOT NULL,
    MaQuyen INT NOT NULL,
    FOREIGN KEY (MaKhachHang) REFERENCES tbKhachHang(MaKhachHang) ON DELETE CASCADE,
    FOREIGN KEY (MaQuyen) REFERENCES tbQuyen(MaQuyen) ON DELETE CASCADE
);
GO


-- ==========================================
-- 12. Bảng tbPhieuNhapHang
-- ==========================================
CREATE TABLE tbPhieuNhapHang (
    MaPhieuNhap UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    MaQuan INT NOT NULL,
    NgayLap DATETIME NOT NULL DEFAULT GETDATE(),
    MaNhanVien INT NOT NULL,
    MaNhaCungCap INT NOT NULL,
    GhiChu NVARCHAR(255) NULL,
    FOREIGN KEY (MaNhanVien) REFERENCES tbNhanVien(MaNhanVien),
    FOREIGN KEY (MaNhaCungCap) REFERENCES tbNhaCungCap(MaNhaCungCap),
    FOREIGN KEY (MaQuan) REFERENCES tbQuanCafe(MaQuan) ON DELETE CASCADE
);
GO

-- ==========================================
-- 13. Bảng tbPhieuNhapChiTiet
-- ==========================================
CREATE TABLE tbPhieuNhapChiTiet (
    MaPhieuNhap UNIQUEIDENTIFIER NOT NULL,
    MaNguyenLieu INT NOT NULL,
    SoLuong DECIMAL(10,2) NOT NULL CHECK (SoLuong > 0),
    DonGia DECIMAL(10,2) NOT NULL CHECK (DonGia > 0),
    ThanhTien AS (SoLuong * DonGia) PERSISTED,
    PRIMARY KEY (MaPhieuNhap, MaNguyenLieu),
    FOREIGN KEY (MaPhieuNhap) REFERENCES tbPhieuNhapHang(MaPhieuNhap) ON DELETE CASCADE,
    FOREIGN KEY (MaNguyenLieu) REFERENCES tbNguyenLieu(MaNguyenLieu) ON DELETE CASCADE
);
GO

-- ==========================================
-- 14. Bảng tbHoaDonBan (Hóa đơn)
-- ==========================================
CREATE TABLE tbHoaDonBan (
    MaHoaDon UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    MaQuan INT NOT NULL,
    NgayLap DATETIME NOT NULL DEFAULT GETDATE(),
    MaNhanVien INT NOT NULL,
    MaKhachHang INT NULL,
    HinhThucThanhToan NVARCHAR(50) NOT NULL CHECK (HinhThucThanhToan IN ('Tiền mặt', 'Chuyển khoản', 'QR')),
    TongTien DECIMAL(10,2) NOT NULL CHECK (TongTien > 0),
    TrangThai NVARCHAR(50) NOT NULL CHECK (TrangThai IN ('Chưa hoàn thành', 'Hoàn thành', 'Đã hủy')),

    FOREIGN KEY (MaNhanVien) REFERENCES tbNhanVien(MaNhanVien),
    FOREIGN KEY (MaKhachHang) REFERENCES tbKhachHang(MaKhachHang),
    FOREIGN KEY (MaQuan) REFERENCES tbQuanCafe(MaQuan) ON DELETE CASCADE
);
GO

-- ==========================================
-- 15. Bảng tbChiTietHoaDonBan (Chi tiết hóa đơn)
-- ==========================================
CREATE TABLE tbChiTietHoaDonBan (
    MaHoaDon UNIQUEIDENTIFIER NOT NULL,
    MaSanPham INT NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    DonGia DECIMAL(10,2) NOT NULL CHECK (DonGia > 0),
    ThanhTien AS (SoLuong * DonGia) PERSISTED,
    PRIMARY KEY (MaHoaDon, MaSanPham),
    FOREIGN KEY (MaHoaDon) REFERENCES tbHoaDonBan(MaHoaDon) ON DELETE CASCADE,
    FOREIGN KEY (MaSanPham) REFERENCES tbSanPham(MaSanPham) ON DELETE CASCADE
);
GO



CREATE TABLE tbTinTuc (
    MaTinTuc INT IDENTITY(1,1) PRIMARY KEY,
    TieuDe NVARCHAR(255) NOT NULL,
    NgayDang DATE NOT NULL,
    NoiDung NVARCHAR(MAX) NOT NULL,
    HinhAnh NVARCHAR(255) NULL
);
GO

CREATE TABLE tbQuanTriVien (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TenNguoiDung NVARCHAR(255) NOT NULL,
    MatKhau NVARCHAR(255) NOT NULL
);
GO

select* from tbQuanTriVien


-- ==========================================
-- Dữ liệu mẫu cho các bảng của TheSpaceCoffee2
-- ==========================================
/***********************************************
 * 1. tbQuanCafe (Chi nhánh/quán cà phê)
 ***********************************************/
INSERT INTO tbQuanCafe (TenQuan, DiaChi, SDT, Email)
VALUES 
  (N'Quán A', N'123 Nguyễn Trãi, TP HCM', '0900000001', 'quana@example.com'),
  (N'Quán B', N'456 Lê Lợi, Hà Nội', '0900000002', 'quanb@example.com');
GO

/***********************************************
 * 2. tbNguyenLieu (Nguyên liệu)
 ***********************************************/
INSERT INTO tbNguyenLieu (TenNguyenLieu, SoLuong, DonViTinh, HanSuDung, DonGia, SoLuongToiThieu)
VALUES
  (N'Ca phê rang', 100, N'kg', '2025-12-31', 200000, 10),
  (N'Trà xanh', 50, N'kg', '2025-10-31', 150000, 5);
GO

/***********************************************
 * 3. tbNhomSanPham (Nhóm sản phẩm)
 ***********************************************/
-- (Dữ liệu mẫu đã có: bạn có thể sử dụng dữ liệu đã import trước đó cho tbNhomSanPham)
-- Ví dụ:
SET IDENTITY_INSERT [dbo].[tbNhomSanPham] ON 

INSERT [dbo].[tbNhomSanPham] ([MaNhomSP], [TenNhomSP]) VALUES (1, N'Cà phê')
INSERT [dbo].[tbNhomSanPham] ([MaNhomSP], [TenNhomSP]) VALUES (2, N'Trà')
INSERT [dbo].[tbNhomSanPham] ([MaNhomSP], [TenNhomSP]) VALUES (3, N'Trà sữa')
INSERT [dbo].[tbNhomSanPham] ([MaNhomSP], [TenNhomSP]) VALUES (4, N'Nước ép/Sinh tố')
INSERT [dbo].[tbNhomSanPham] ([MaNhomSP], [TenNhomSP]) VALUES (5, N'Các loại đồ uống khác')
SET IDENTITY_INSERT [dbo].[tbNhomSanPham] OFF
GO



select * from tbNhomSanPham
select * from tbSanPham
select* from tbGioHang
/***********************************************
 * 4. tbSanPham (Sản phẩm - đã có dữ liệu mẫu)
 ***********************************************/
SET IDENTITY_INSERT [dbo].[tbSanPham] ON 

INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (1, N'Cà phê sữa đá', 39000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'ca-phe-sua-da.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (2, N'Cà phê sữa nóng', 39000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'ca-phe-sua-nong.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (3, N'Bạc xỉu đá', 29000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'bac-xiu-da.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (4, N'Bạc xỉu nóng', 39000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'bac-xiu-nong.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (5, N'Cà phê đen', 29000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'ca-phe-den.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (6, N'Cà phê đen nóng', 39000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'ca-phe-den-nong.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (7, N'Caramel Macchiato đá', 55000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'caramel-macchiato-da.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (8, N'Caramel Macchiato nóng', 55000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'caramel-macchiato-nong.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (9, N'Latte đá', 55000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'latte-da.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (10, N'Latte nóng', 55000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'latte-nong.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (11, N'Americano đá', 45000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'americano-da.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (12, N'Americano nóng', 45000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'americano-nong.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (13, N'Capucchino đá', 55000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'capucchino-da.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (14, N'Capucchino nóng', 55000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'capucchino-nong.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (15, N'Espresso đá', 49000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'espresso-da.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (16, N'Espresso nóng', 45000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'espresso-nong.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (17, N'Cold Brew truyền thống', 45000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'cold-brew-truyen-thong.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (18, N'Cold Brew sữa tươi', 49000.0000, N'Cà phê là thức uống tuyệt vời cho những người yêu thích hương vị đậm đà và năng lượng bùng nổ. Cà phê được làm từ hạt cà phê rang xay, có chứa caffeine và các chất chống oxy hóa có lợi cho sức khỏe. Bạn có thể thưởng thức cà phê theo nhiều cách khác nhau, từ cà phê đen đơn giản đến cà phê sữa đá ngọt ngào, hay cà phê latte béo ngậy. Cà phê là bạn đồng hành lý tưởng cho mỗi buổi sáng, giúp bạn tỉnh táo và sẵn sàng cho một ngày mới. Hãy thử cà phê ngay hôm nay và cảm nhận sự khác biệt!', N'cold-brew-sua-tuoi.jpeg', NULL, 1)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (19, N'Cacao nóng', 30000.0000, N'Cacao nóng là một loại thức uống ấm áp và thơm ngon, được làm từ bột cacao hoặc sô cô la tan chảy với sữa hoặc nước. Bạn có thể thêm đường, bột quế, kem tươi hoặc các nguyên liệu khác để tăng hương vị và độ béo. Cacao nóng có nhiều lợi ích cho sức khỏe như cung cấp chất chống oxy hóa, tăng cường tuần hoàn máu, giảm đau nhức và cải thiện tinh thần. Cacao nóng là một lựa chọn tuyệt vời cho những người yêu thích thức uống ấm nóng và ngọt ngào.', N'cacao-nong.jpeg', NULL, 5)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (20, N'Sữa chua mận', 28000.0000, N'Sữa chua là một loại thực phẩm ngon miệng và tốt cho sức khỏe, được làm từ sữa tươi hoặc sữa bột lên men với vi sinh vật có lợi. Bạn có thể chọn nhiều hương vị khác nhau như chanh, dâu, việt quất, xoài, nho hoặc kết hợp nhiều loại trái cây lại với nhau. Sữa chua có nhiều lợi ích cho sức khỏe như cung cấp canxi, protein, probiotic và vitamin, giúp tiêu hóa tốt, tăng cường hệ miễn dịch và ngăn ngừa nhiễm trùng. Sữa chua là một lựa chọn hoàn hảo cho những người yêu thích thực phẩm mát lạnh và giàu dinh dưỡng.', N'sua-chua-man.jpeg', NULL, 5)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (21, N'Sữa chua dâu', 28000.0000, N'Sữa chua là một loại thực phẩm ngon miệng và tốt cho sức khỏe, được làm từ sữa tươi hoặc sữa bột lên men với vi sinh vật có lợi. Bạn có thể chọn nhiều hương vị khác nhau như chanh, dâu, việt quất, xoài, nho hoặc kết hợp nhiều loại trái cây lại với nhau. Sữa chua có nhiều lợi ích cho sức khỏe như cung cấp canxi, protein, probiotic và vitamin, giúp tiêu hóa tốt, tăng cường hệ miễn dịch và ngăn ngừa nhiễm trùng. Sữa chua là một lựa chọn hoàn hảo cho những người yêu thích thực phẩm mát lạnh và giàu dinh dưỡng.', N'sua-chua-dau.jpeg', NULL, 5)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (22, N'Nước táo ép', 45000.0000, N'Nước ép sinh tố trái cây là một loại thức uống tươi mát và ngon lành, được làm từ các loại trái cây tươi hoặc đông lạnh xay nhuyễn với nước, sữa hoặc kem. Bạn có thể chọn nhiều hương vị khác nhau như dâu, cam, chuối, xoài, dứa, kiwi hoặc kết hợp nhiều loại trái cây lại với nhau. Nước ép sinh tố trái cây có nhiều lợi ích cho sức khỏe như cung cấp vitamin, khoáng chất, chất xơ và chất chống oxy hóa, giúp thanh lọc cơ thể, tăng cường năng lượng và làm đẹp da. Nước ép sinh tố trái cây là một lựa chọn hoàn hảo cho những người yêu thích thức uống tự nhiên và đầy dinh dưỡng.', N'nuoc-tao-ep.jpeg', NULL, 4)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (23, N'Nước dâu ép', 45000.0000, N'Nước ép sinh tố trái cây là một loại thức uống tươi mát và ngon lành, được làm từ các loại trái cây tươi hoặc đông lạnh xay nhuyễn với nước, sữa hoặc kem. Bạn có thể chọn nhiều hương vị khác nhau như dâu, cam, chuối, xoài, dứa, kiwi hoặc kết hợp nhiều loại trái cây lại với nhau. Nước ép sinh tố trái cây có nhiều lợi ích cho sức khỏe như cung cấp vitamin, khoáng chất, chất xơ và chất chống oxy hóa, giúp thanh lọc cơ thể, tăng cường năng lượng và làm đẹp da. Nước ép sinh tố trái cây là một lựa chọn hoàn hảo cho những người yêu thích thức uống tự nhiên và đầy dinh dưỡng.', N'nuoc-dau-ep.jpeg', NULL, 4)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (24, N'Nước cam ép', 45000.0000, N'Nước ép sinh tố trái cây là một loại thức uống tươi mát và ngon lành, được làm từ các loại trái cây tươi hoặc đông lạnh xay nhuyễn với nước, sữa hoặc kem. Bạn có thể chọn nhiều hương vị khác nhau như dâu, cam, chuối, xoài, dứa, kiwi hoặc kết hợp nhiều loại trái cây lại với nhau. Nước ép sinh tố trái cây có nhiều lợi ích cho sức khỏe như cung cấp vitamin, khoáng chất, chất xơ và chất chống oxy hóa, giúp thanh lọc cơ thể, tăng cường năng lượng và làm đẹp da. Nước ép sinh tố trái cây là một lựa chọn hoàn hảo cho những người yêu thích thức uống tự nhiên và đầy dinh dưỡng.', N'nuoc-cam-ep.jpeg', NULL, 4)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (25, N'Sinh tố chanh', 50000.0000, N'Nước ép sinh tố trái cây là một loại thức uống tươi mát và ngon lành, được làm từ các loại trái cây tươi hoặc đông lạnh xay nhuyễn với nước, sữa hoặc kem. Bạn có thể chọn nhiều hương vị khác nhau như dâu, cam, chuối, xoài, dứa, kiwi hoặc kết hợp nhiều loại trái cây lại với nhau. Nước ép sinh tố trái cây có nhiều lợi ích cho sức khỏe như cung cấp vitamin, khoáng chất, chất xơ và chất chống oxy hóa, giúp thanh lọc cơ thể, tăng cường năng lượng và làm đẹp da. Nước ép sinh tố trái cây là một lựa chọn hoàn hảo cho những người yêu thích thức uống tự nhiên và đầy dinh dưỡng.', N'sinh-to-chanh.jpeg', NULL, 4)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (26, N'Sinh tố dâu', 55000.0000, N'Nước ép sinh tố trái cây là một loại thức uống tươi mát và ngon lành, được làm từ các loại trái cây tươi hoặc đông lạnh xay nhuyễn với nước, sữa hoặc kem. Bạn có thể chọn nhiều hương vị khác nhau như dâu, cam, chuối, xoài, dứa, kiwi hoặc kết hợp nhiều loại trái cây lại với nhau. Nước ép sinh tố trái cây có nhiều lợi ích cho sức khỏe như cung cấp vitamin, khoáng chất, chất xơ và chất chống oxy hóa, giúp thanh lọc cơ thể, tăng cường năng lượng và làm đẹp da. Nước ép sinh tố trái cây là một lựa chọn hoàn hảo cho những người yêu thích thức uống tự nhiên và đầy dinh dưỡng.', N'sinh-to-dau.jpeg', NULL, 4)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (27, N'Sinh tố xoài', 55000.0000, N'Nước ép sinh tố trái cây là một loại thức uống tươi mát và ngon lành, được làm từ các loại trái cây tươi hoặc đông lạnh xay nhuyễn với nước, sữa hoặc kem. Bạn có thể chọn nhiều hương vị khác nhau như dâu, cam, chuối, xoài, dứa, kiwi hoặc kết hợp nhiều loại trái cây lại với nhau. Nước ép sinh tố trái cây có nhiều lợi ích cho sức khỏe như cung cấp vitamin, khoáng chất, chất xơ và chất chống oxy hóa, giúp thanh lọc cơ thể, tăng cường năng lượng và làm đẹp da. Nước ép sinh tố trái cây là một lựa chọn hoàn hảo cho những người yêu thích thức uống tự nhiên và đầy dinh dưỡng.', N'sinh-to-xoai.jpeg', NULL, 4)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (28, N'Trà sữa', 20000.0000, N'Trà sữa là một loại thức uống ngon miệng và bổ dưỡng, được làm từ trà đen hoặc trà xanh pha với sữa tươi hoặc sữa đặc. Bạn có thể thêm đường, kem, trân châu, thạch hoặc các nguyên liệu khác để tăng hương vị và độ ngọt. Trà sữa có nhiều lợi ích cho sức khỏe như cung cấp chất chống oxy hóa, tăng cường hệ miễn dịch, giảm căng thẳng và cải thiện tâm trạng. Trà sữa là một lựa chọn tuyệt vời cho những người yêu thích thức uống mát lạnh và béo ngậy.', N'tra-sua.jpeg', NULL, 3)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (29, N'Trà sữa phô mai tươi', 28000.0000, N'Trà sữa là một loại thức uống ngon miệng và bổ dưỡng, được làm từ trà đen hoặc trà xanh pha với sữa tươi hoặc sữa đặc. Bạn có thể thêm đường, kem, trân châu, thạch hoặc các nguyên liệu khác để tăng hương vị và độ ngọt. Trà sữa có nhiều lợi ích cho sức khỏe như cung cấp chất chống oxy hóa, tăng cường hệ miễn dịch, giảm căng thẳng và cải thiện tâm trạng. Trà sữa là một lựa chọn tuyệt vời cho những người yêu thích thức uống mát lạnh và béo ngậy.', N'tra-sua-pho-mai-tuoi.jpeg', NULL, 3)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (30, N'Trà sữa matcha', 40000.0000, N'Trà sữa là một loại thức uống ngon miệng và bổ dưỡng, được làm từ trà đen hoặc trà xanh pha với sữa tươi hoặc sữa đặc. Bạn có thể thêm đường, kem, trân châu, thạch hoặc các nguyên liệu khác để tăng hương vị và độ ngọt. Trà sữa có nhiều lợi ích cho sức khỏe như cung cấp chất chống oxy hóa, tăng cường hệ miễn dịch, giảm căng thẳng và cải thiện tâm trạng. Trà sữa là một lựa chọn tuyệt vời cho những người yêu thích thức uống mát lạnh và béo ngậy.', N'tra-sua-matcha.jpeg', NULL, 3)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (31, N'Trà sữa Ô Long', 22000.0000, N'Trà sữa là một loại thức uống ngon miệng và bổ dưỡng, được làm từ trà đen hoặc trà xanh pha với sữa tươi hoặc sữa đặc. Bạn có thể thêm đường, kem, trân châu, thạch hoặc các nguyên liệu khác để tăng hương vị và độ ngọt. Trà sữa có nhiều lợi ích cho sức khỏe như cung cấp chất chống oxy hóa, tăng cường hệ miễn dịch, giảm căng thẳng và cải thiện tâm trạng. Trà sữa là một lựa chọn tuyệt vời cho những người yêu thích thức uống mát lạnh và béo ngậy.', N'tra-sua-o-long.jpeg', NULL, 3)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (32, N'Trà sữa Sô cô la', 22000.0000, N'Trà sữa là một loại thức uống ngon miệng và bổ dưỡng, được làm từ trà đen hoặc trà xanh pha với sữa tươi hoặc sữa đặc. Bạn có thể thêm đường, kem, trân châu, thạch hoặc các nguyên liệu khác để tăng hương vị và độ ngọt. Trà sữa có nhiều lợi ích cho sức khỏe như cung cấp chất chống oxy hóa, tăng cường hệ miễn dịch, giảm căng thẳng và cải thiện tâm trạng. Trà sữa là một lựa chọn tuyệt vời cho những người yêu thích thức uống mát lạnh và béo ngậy.', N'tra-sua-so-co-la.jpeg', NULL, 3)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (33, N'Trà sữa bạc hà', 22000.0000, N'Trà sữa là một loại thức uống ngon miệng và bổ dưỡng, được làm từ trà đen hoặc trà xanh pha với sữa tươi hoặc sữa đặc. Bạn có thể thêm đường, kem, trân châu, thạch hoặc các nguyên liệu khác để tăng hương vị và độ ngọt. Trà sữa có nhiều lợi ích cho sức khỏe như cung cấp chất chống oxy hóa, tăng cường hệ miễn dịch, giảm căng thẳng và cải thiện tâm trạng. Trà sữa là một lựa chọn tuyệt vời cho những người yêu thích thức uống mát lạnh và béo ngậy.', N'tra-sua-bac-ha.jpeg', NULL, 3)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (34, N'Trà sữa dâu tây', 22000.0000, N'Trà sữa là một loại thức uống ngon miệng và bổ dưỡng, được làm từ trà đen hoặc trà xanh pha với sữa tươi hoặc sữa đặc. Bạn có thể thêm đường, kem, trân châu, thạch hoặc các nguyên liệu khác để tăng hương vị và độ ngọt. Trà sữa có nhiều lợi ích cho sức khỏe như cung cấp chất chống oxy hóa, tăng cường hệ miễn dịch, giảm căng thẳng và cải thiện tâm trạng. Trà sữa là một lựa chọn tuyệt vời cho những người yêu thích thức uống mát lạnh và béo ngậy.', N'tra-sua-dau-tay.jpeg', NULL, 3)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (35, N'Trà nhãn', 50000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-nhan.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (36, N'Trà vải', 50000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-vai.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (37, N'Trà lài', 50000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-lai.jpg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (38, N'Hồng trà', 70000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'hong-tra.png', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (39, N'Trà đào', 50000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-dao.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (40, N'Hồng trà chanh', 40000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'hong-tra-chanh.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (41, N'Trà hoa hồng', 50000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-hoa-hong.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (42, N'Trà đào sữa', 40000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-dao-sua.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (43, N'Trà chanh', 25000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-chanh.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (44, N'Trà đào dâu tây', 28000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-dao-dau-tay.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (45, N'Trà đào bưởi', 28000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-dao-buoi.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (46, N'Trà xoài', 28000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-xoai.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (47, N'Trà mận hạt sen', 28000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-man-hat-sen.jpg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (48, N'Hồng trà bưởi mật ong', 28000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'hong-tra-buoi-mat-ong.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (49, N'Trà dứa', 28000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-dua.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (50, N'Trà Ô Long dâu', 50000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-o-long-dau.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (51, N'Trà Ô Long sữa', 45000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-o-long-sua.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (52, N'Trà Ô Long mãng cầu', 54000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-o-long-mang-cau.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (53, N'Trà Ô Long trân châu', 49000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'tra-o-long-tran-chau.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (54, N'Matcha', 45000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'matcha.jpeg', NULL, 2)
INSERT [dbo].[tbSanPham] ([MaSanPham], [TenSanPham], [GiaBan], [MoTa], [HinhAnh], [GhiChu], [MaNhomSP]) VALUES (55, N'Matcha đậu đỏ', 49000.0000, N'Trà là thức uống thanh mát và thơm ngon cho những người yêu thích sự nhẹ nhàng và dịu êm. Trà được làm từ lá trà phơi khô, có chứa các chất chống oxy hóa và flavonoid có lợi cho sức khỏe. Bạn có thể thưởng thức trà theo nhiều cách khác nhau, từ trà xanh đơn giản đến trà sữa trân châu đầy hấp dẫn, hay trà hoa quả nhiều màu sắc. Trà là bạn đồng hành lý tưởng cho mỗi buổi chiều, giúp bạn thư giãn và xua tan mệt mỏi. Hãy thử trà ngay hôm nay và cảm nhận sự khác biệt!', N'matcha-dau-do.jpg', NULL, 2)
SET IDENTITY_INSERT [dbo].[tbSanPham] OFF
GO

/***********************************************
 * 1. tbQuanCafe (Chi nhánh/quán cà phê)
 * Khóa chính: MaQuan INT IDENTITY
 ***********************************************/
INSERT INTO tbQuanCafe (TenQuan, DiaChi, SDT, Email)
VALUES 
  (N'Quán A', N'123 Nguyễn Trãi, TP HCM', '0900000001', 'quana@example.com'),
  (N'Quán B', N'456 Lê Lợi, Hà Nội', '0900000002', 'quanb@example.com');
GO

select * from tbQuanCafe

/***********************************************
 * 2. tbNguyenLieu (Nguyên liệu)
 * Khóa chính: MaNguyenLieu INT IDENTITY
 ***********************************************/
INSERT INTO tbNguyenLieu (TenNguyenLieu, SoLuong, DonViTinh, HanSuDung, DonGia, SoLuongToiThieu)
VALUES
  (N'Cà phê rang', 100, N'kg', '2025-12-31', 200000, 10),
  (N'Trà xanh', 50, N'kg', '2025-10-31', 150000, 5);
GO

INSERT INTO tbNguyenLieu (TenNguyenLieu, SoLuong, DonViTinh, HanSuDung, DonGia, SoLuongToiThieu)
VALUES

  (N'Đường trắng', 200, N'kg', '2026-03-31', 100000, 20),
  (N'Sữa tươi', 500, N'lít', '2025-11-30', 25000, 50),
  (N'Bột sô cô la', 80, N'kg', '2025-12-15', 300000, 8),
  (N'Hạt cacao', 60, N'kg', '2026-02-28', 350000, 6),
  (N'Hạt hạnh nhân', 40, N'kg', '2026-01-15', 400000, 5),
  (N'Bột vani', 30, N'kg', '2025-09-30', 500000, 3),
  (N'Nước lọc', 1000, N'lít', '2027-01-01', 5000, 100),
  (N'Bột cocoa', 70, N'kg', '2025-11-15', 280000, 7),
  (N'Kem tươi', 150, N'kg', '2025-08-31', 220000, 10),
  (N'Bột trà xanh', 50, N'kg', '2025-10-05', 180000, 5),
  (N'Bột gừng', 25, N'kg', '2026-05-31', 210000, 3),
  (N'Bột quế', 30, N'kg', '2026-06-30', 230000, 4),
  (N'Lá bạc hà', 15, N'kg', '2025-12-31', 450000, 2),
  (N'Bột đậu nành', 90, N'kg', '2026-03-15', 190000, 10),
  (N'Nước cốt dừa', 80, N'kg', '2026-07-31', 270000, 5),
  (N'Hạt điều', 35, N'kg', '2026-02-15', 500000, 3),
  (N'Bột matcha', 40, N'kg', '2026-08-31', 600000, 4),
  (N'Sữa bột', 70, N'kg', '2026-09-30', 150000, 7),
  (N'Bột nghệ', 45, N'kg', '2026-05-15', 250000, 3),
  (N'Hạt macca', 30, N'kg', '2026-04-30', 550000, 2);
GO

INSERT INTO tbNguyenLieu (TenNguyenLieu, SoLuong, DonViTinh, HanSuDung, DonGia, SoLuongToiThieu)
VALUES
  (N'Nước ép cam tự nhiên', 120, N'lít', '2026-01-15', 25000, 15),
  (N'Nước ép táo xanh', 100, N'lít', '2026-02-15', 28000, 10),
  (N'Nước ép nho', 80, N'lít', '2026-03-10', 32000, 12),
  (N'Nước ép lựu', 90, N'lít', '2026-04-01', 35000, 8),
  (N'Nước ép dứa', 110, N'lít', '2026-05-20', 27000, 10),
  (N'Nước ép mâm xôi', 70, N'lít', '2026-06-15', 40000, 5),
  (N'Nước ép kiwi', 60, N'lít', '2026-07-10', 45000, 4),
  (N'Nước ép bơ', 50, N'lít', '2026-08-05', 48000, 6),
  (N'Nước ép cà rốt', 130, N'lít', '2026-09-30', 22000, 20),
  (N'Nước ép cải xoăn', 40, N'lít', '2026-10-20', 30000, 5),
  (N'Nước ép cần tây', 100, N'lít', '2026-11-15', 26000, 8),
  (N'Nước ép lựu đỏ', 85, N'lít', '2026-12-10', 36000, 10),
  (N'Bột protein whey', 150, N'kg', '2027-01-31', 800000, 10),
  (N'Bột protein đậu nành', 140, N'kg', '2027-02-28', 750000, 12),
  (N'Bột protein gạo', 100, N'kg', '2027-03-31', 700000, 15),
  (N'Bột protein hạt mắc ca', 90, N'kg', '2027-04-30', 850000, 8),
  (N'Bột hồng đào', 60, N'kg', '2027-05-15', 600000, 5),
  (N'Bột dâu tây', 70, N'kg', '2027-06-20', 650000, 5),
  (N'Bột xoài', 50, N'kg', '2027-07-10', 680000, 4),
  (N'Bột việt quất', 55, N'kg', '2027-08-05', 720000, 6),
  (N'Bột rau má', 80, N'kg', '2027-09-01', 500000, 10),
  (N'Hạt chia', 40, N'kg', '2027-10-15', 300000, 5),
  (N'Hạt lanh', 35, N'kg', '2027-11-20', 280000, 4),
  (N'Hạt hướng dương', 60, N'kg', '2027-12-25', 260000, 6),
  (N'Hạt bí ngô', 45, N'kg', '2028-01-15', 320000, 5),
  (N'Hạt óc chó', 50, N'kg', '2028-02-10', 450000, 3),
  (N'Hạt lạc', 70, N'kg', '2028-03-05', 210000, 10),
  (N'Mật ong hoa hồng', 90, N'kg', '2028-04-01', 550000, 7),
  (N'Mật ong rừng', 100, N'kg', '2028-05-01', 600000, 8),
  (N'Mật ong xoài', 80, N'kg', '2028-06-01', 580000, 7),
  (N'Mật ong bướm', 75, N'kg', '2028-07-15', 620000, 6),
  (N'Nước mía', 500, N'lít', '2028-08-30', 12000, 50),
  (N'Nước mía tự nhiên', 450, N'lít', '2028-09-15', 13000, 40),
  (N'Sinh tố dâu tây', 200, N'lít', '2028-10-10', 35000, 20),
  (N'Sinh tố chuối', 220, N'lít', '2028-11-05', 33000, 18),
  (N'Sinh tố xoài', 180, N'lít', '2028-12-01', 37000, 15),
  (N'Sinh tố dứa', 210, N'lít', '2029-01-20', 34000, 20),
  (N'Sinh tố kiwi', 190, N'lít', '2029-02-18', 36000, 16),
  (N'Bột yến mạch', 130, N'kg', '2029-03-15', 400000, 12),
  (N'Bột cacao hỗn hợp', 120, N'kg', '2029-04-10', 420000, 10);
GO



select* from tbNguyenLieu
delete from tbNguyenLieu

select* from tbPhieuNhapHang
delete from tbPhieuNhapHang

select* from tbPhieuNhapChiTiet
delete from tbPhieuNhapChiTiet
/***********************************************
 * 5. tbNhaCungCap (Nhà cung cấp)
 * Khóa chính: MaNhaCungCap UNIQUEIDENTIFIER
 ***********************************************/
 DELETE FROM tbNguyenLieu
WHERE MaNguyenLieu BETWEEN 21 AND 62;
GO


INSERT INTO tbNhaCungCap ( TenNhaCungCap, DiaChi, SDTNCC, STK)
VALUES
  ( N'NCC 1', N'12 Trần Phú, TP HCM', '0901234567', '123456789'),
  ( N'NCC 2', N'34 Phan Đình Phùng, Hà Nội', '0907654321', '987654321');
GO

/***********************************************
 * 6. tbNhanVien (Nhân viên)
 * Khóa chính: MaNhanVien INT IDENTITY
 * MaQuan là khóa ngoại tham chiếu đến tbQuanCafe (INT)
 ***********************************************/
-- Giả sử hàng đầu tiên của tbQuanCafe có MaQuan = 1 và hàng thứ hai có MaQuan = 2
INSERT INTO tbNhanVien (MaQuan, HoTen, DiaChi, NgaySinh, GioiTinh, ChucVu, SDT, SoCCCD, Email, LuongCoBan, HeSoLuong)
VALUES(2, N'Thùy Linh', N'456 Lê Lợi', '1992-02-02', 'Nữ', N'Quản lý', '0903333454', '987854321', 'tl@example.com', 8000000, 1.5);
  (1, N'Nguyễn Văn A', N'123 Nguyễn Trãi', '1990-01-01', 'Nam', N'Barista', '0901111222', '123456789', 'nvA@example.com', 5000000, 1.2),
  (2, N'Lê Thị B', N'456 Lê Lợi', '1992-02-02', N'Nữ', N'Quản lý', '0903333444', '987654321', 'nvB@example.com', 8000000, 1.5);
  
GO

/***********************************************
 * 7. tbKhachHang (Khách hàng)
 * Khóa chính: MaKhachHang INT IDENTITY
 ***********************************************/
INSERT INTO tbKhachHang (TenKhachHang, SDTKhachHang, DiaChi)
VALUES
  (N'Phạm Văn C', '0912345678', N'789 Trần Hưng Đạo'),
  (N'Trần Thị D', '0987654321', N'101 Lý Thái Tổ');
GO

/***********************************************
 * 8. tbGioHang (Giỏ hàng)
 * Khóa chính ghép: (MaKhachHang, MaSanPham)
 * Giả sử: khách hàng đầu tiên (MaKhachHang = 1) mua sản phẩm có MaSanPham = 1,
 * khách hàng thứ hai (MaKhachHang = 2) mua sản phẩm có MaSanPham = 2.
 ***********************************************/
INSERT INTO tbGioHang (MaKhachHang, MaSanPham, SoLuong)
VALUES
  (1, 1, 2),
  (2, 2, 1);
GO

/***********************************************
 * 9. tbQuyen (Quyền/Role)
 * Khóa chính: MaQuyen INT IDENTITY
 ***********************************************/
INSERT INTO tbQuyen (TenQuyen)
VALUES
  (N'Admin'),
  (N'User');
GO

INSERT INTO tbQuyen (TenQuyen)
VALUES (N'Employee');
GO


/***********************************************
 * 10. tbTaiKhoan (Tài khoản nhân viên)
 * Khóa chính: MaTaiKhoan INT IDENTITY
 * Giả sử: sử dụng MaNhanVien = 1 và MaQuyen = 1 (hàng đầu tiên của tbNhanVien và tbQuyen)
 ***********************************************/
INSERT INTO tbTaiKhoan (TenTaiKhoan, MatKhau, MaNhanVien, MaQuyen)
VALUES
  (N'thuylinh', '969687dd6dce4d871484c6a0b4db71ee9a16bf97a40be4483a86e3b2b046b849', 6, 1);
GO


select* from tbTaiKhoan
select* from tbQuanTriVien
select* from tbNhanVien


select* from tbQuanCafe

select* from tbKhachHang
select* from tbTaiKhoanKH
select* from tbGioHang
select* from tbHoaDonBan
select* from tbChiTietHoaDonBan

select* from tbGioHang
select* from tbTaiKhoan
select* from tbNhanVien
select* from tbPhieuNhapChiTiet
select* from tbPhieuNhapHang
select* from tbNguyenLieu
select* from tbNhaCungCap
/***********************************************
 * 11. tbTaiKhoanKH (Tài khoản khách hàng)
 * Khóa chính: MaTaiKhoan INT IDENTITY
 * Giả sử: sử dụng MaKhachHang = 1 và MaQuyen = 2 (hàng đầu tiên của tbKhachHang, hàng thứ hai của tbQuyen)
 ***********************************************/
INSERT INTO tbTaiKhoanKH (TenTaiKhoan, MatKhau, MaKhachHang, MaQuyen)
VALUES
  (N'khuser1', 'pass123', 1, 2);
GO

/***********************************************
 * 12. tbPhieuNhapHang (Phiếu nhập hàng)
 * Khóa chính: MaPhieuNhap UNIQUEIDENTIFIER (mặc định NEWID())
 * Các khóa ngoại:
 *   - MaQuan: tham chiếu đến tbQuanCafe (INT) -> sử dụng 1 (Quán A)
 *   - MaNhanVien: tham chiếu đến tbNhanVien (INT) -> sử dụng 1
 *   - MaNhaCungCap: tham chiếu đến tbNhaCungCap (UNIQUEIDENTIFIER)
 ***********************************************/
DECLARE @MaPhieuNhap UNIQUEIDENTIFIER = NEWID();

INSERT INTO tbPhieuNhapHang (MaPhieuNhap, MaQuan, NgayLap, MaNhanVien, MaNhaCungCap, GhiChu)
VALUES (@MaPhieuNhap, 1, GETDATE(), 1, 1, N'Phiếu nhập đầu tháng');

select* from tbPhieuNhapHang

/***********************************************
 * 13. tbPhieuNhapChiTiet (Chi tiết phiếu nhập)
 * Khóa chính ghép: (MaPhieuNhap, MaNguyenLieu)
 * MaNguyenLieu: tham chiếu đến tbNguyenLieu (INT) -> sử dụng 1 (Ca phê rang)
 ***********************************************/
INSERT INTO tbPhieuNhapChiTiet (MaPhieuNhap, MaNguyenLieu, SoLuong, DonGia)
VALUES (@MaPhieuNhap, 1, 10, 180000);

select* from tbPhieuNhapChiTiet

/***********************************************
 * 14. tbHoaDonBan (Hóa đơn)
 * Khóa chính: MaHoaDon UNIQUEIDENTIFIER (mặc định NEWID())
 * Các khóa ngoại:
 *   - MaQuan: tham chiếu đến tbQuanCafe (INT) -> sử dụng 1
 *   - MaNhanVien: tham chiếu đến tbNhanVien (INT) -> sử dụng 1
 *   - MaKhachHang: tham chiếu đến tbKhachHang (INT) -> sử dụng 1
 ***********************************************/
DECLARE @MaHoaDon UNIQUEIDENTIFIER = NEWID();

INSERT INTO tbHoaDonBan (MaHoaDon, MaQuan, NgayLap, MaNhanVien, MaKhachHang, HinhThucThanhToan, TongTien, TrangThai, TrangThaiThanhToan)
VALUES
  (@MaHoaDon, 1, GETDATE(), 2, 2, N'Tiền mặt', 390000, 'Hoàn thành', 1);

  select * from tbHoaDonBan

/***********************************************
 * 15. tbChiTietHoaDonBan (Chi tiết hóa đơn)
 * Khóa chính ghép: (MaHoaDon, MaSanPham)
 * Giả sử: hóa đơn @MaHoaDon chứa sản phẩm có MaSanPham = 1
 ***********************************************/

INSERT INTO tbChiTietHoaDonBan (MaHoaDon, MaSanPham, SoLuong, DonGia)
VALUES
  (@MaHoaDon, 2, 10, 39000);
GO



select*from tbHoaDonBan
select* from tbChiTietHoaDonBan

SET IDENTITY_INSERT [dbo].[tbTinTuc] ON 

INSERT [dbo].[tbTinTuc] ([MaTinTuc], [TieuDe], [NgayDang], [NoiDung], [HinhAnh]) VALUES (1, N'Chào mừng đến với THE SPACE COFFEE', CAST(N'2023-01-20' AS Date), N'Cửa hàng cà phê THE SPACE COFFEE là một địa điểm thưởng thức cà phê độc đáo và sáng tạo, với không gian thiết kế theo phong cách vũ trụ hiện đại và ấn tượng.
Cửa hàng cà phê THE SPACE COFFEE cung cấp nhiều loại cà phê chất lượng cao, được chọn lọc từ những hạt cà phê tươi ngon nhất và rang xay tại chỗ. Bạn có thể thưởng thức những ly cà phê đậm đà và thơm ngon, với nhiều hương vị khác nhau như cà phê sữa, cappuccino, latte, mocha, americano, espresso hay cold brew.
Ngoài ra, cửa hàng cà phê The Space Coffee còn có nhiều loại thức uống khác như trà, sinh tố, nước ép, soda và các món ăn nhẹ như bánh ngọt, bánh mì, sandwich, salad và pizza. Bạn có thể lựa chọn thức uống và món ăn theo sở thích và khẩu vị của mình.
Cửa hàng cà phê THE SPACE COFFEE là một nơi lý tưởng để bạn có những giây phút thư giãn và tận hưởng cuộc sống. Bạn có thể đến đây để học tập, làm việc, gặp gỡ bạn bè, hẹn hò hay tổ chức các sự kiện và tiệc nhỏ. Cửa hàng cà phê THE SPACE COFFEE luôn sẵn sàng phục vụ bạn với thái độ nhiệt tình và chuyên nghiệp.', N'tt00001.jpg')
INSERT [dbo].[tbTinTuc] ([MaTinTuc], [TieuDe], [NgayDang], [NoiDung], [HinhAnh]) VALUES (2, N'Ưu đãi lần đầu của chúng tôi', CAST(N'2023-01-21' AS Date), N'Bạn là một tín đồ của cà phê và yêu thích không gian vũ trụ? Bạn muốn có những trải nghiệm mới lạ và thú vị khi thưởng thức cà phê? Nếu vậy, bạn không thể bỏ qua cơ hội hấp dẫn này từ cửa hàng cà phê THE SPACE COFFEE.

Chỉ trong tháng 4 này, cửa hàng cà phê THE SPACE COFFEE dành tặng cho bạn nhiều ưu đãi hấp dẫn như sau:

Giảm giá 20% cho tất cả các loại cà phê khi mua mang về hoặc giao hàng tận nơi.
Tặng một ly cà phê miễn phí cho khách hàng khi mua hai ly cà phê bất kỳ.
Tặng một phiếu quà tặng trị giá 100.000 đồng cho khách hàng khi tích lũy đủ 10 dấu trên thẻ thành viên.
Tặng một voucher giảm giá 50% cho khách hàng khi check-in và chia sẻ bài viết về cửa hàng cà phê THE SPACE COFFEE trên Facebook hoặc Instagram.
Đây là những ưu đãi vô cùng hấp dẫn mà bạn không nên bỏ lỡ. Hãy nhanh chóng đến với cửa hàng cà phê THE SPACE COFFEE để thưởng thức những ly cà phê ngon tuyệt và khám phá không gian vũ trụ độc đáo. Cửa hàng cà phê THE SPACE COFFEE luôn chào đón bạn với sự phục vụ tận tâm và chuyên nghiệp.', N'tt00002.jpg')
INSERT [dbo].[tbTinTuc] ([MaTinTuc], [TieuDe], [NgayDang], [NoiDung], [HinhAnh]) VALUES (3, N'Thư giãn và tận hưởng ly cà phê ngon', CAST(N'2023-01-22' AS Date), N'Bạn đang tìm kiếm một nơi để thư giãn và tận hưởng ly cà phê ngon? Hãy đến với THE SPACE COFFEE, cửa hàng cà phê mới mở tại số 3 phố Cầu Giấy, quận Đống Đa. THE SPACE COFFEE là một không gian hiện đại và sang trọng, với thiết kế nội thất theo phong cách vũ trụ. Bạn sẽ được chiêm ngưỡng những hình ảnh đẹp mắt của các hành tinh, sao và thiên hà trên các bức tường và trần nhà. Bên cạnh đó, bạn cũng có thể thưởng thức những món cà phê đặc biệt của THE SPACE COFFEE, như Milky Way Latte, Galaxy Frappe hay Starry Night Mocha. Các món cà phê của THE SPACE COFFEE được pha chế từ những hạt cà phê chất lượng cao, mang đến cho bạn hương vị thơm ngon và đậm đà. Ngoài ra, bạn cũng có thể thử những món bánh ngọt và đồ ăn nhẹ hấp dẫn khác tại THE SPACE COFFEE. Hãy đến với THE SPACE COFFEE để có những giây phút thư giãn và tận hưởng không gian vũ trụ tuyệt vời. THE SPACE COFFEE - Cà phê không giới hạn!', N'tt00003.jpg')
INSERT [dbo].[tbTinTuc] ([MaTinTuc], [TieuDe], [NgayDang], [NoiDung], [HinhAnh]) VALUES (4, N'Mùa hè đến rồi', CAST(N'2023-01-22' AS Date), N'Mùa hè đến rồi, bạn đã có kế hoạch gì để giải nhiệt chưa? Nếu bạn đang tìm kiếm một nơi để trốn khỏi cái nóng oi bức của thành phố, hãy đến với THE SPACE COFFEE, cửa hàng cà phê vũ trụ độc đáo và lạ mắt. Tại đây, bạn sẽ được thưởng thức những ly cà phê mát lạnh và ngon miệng, như Galaxy Frappe, Starry Night Mocha hay Milky Way Latte. Bạn cũng có thể chọn những món đồ uống khác như trà sữa, sinh tố hay nước ép trái cây. Không chỉ vậy, bạn còn được ngắm nhìn những hình ảnh tuyệt đẹp của vũ trụ trên các bức tường và trần nhà, tạo cho bạn cảm giác như đang lạc vào một thế giới khác. THE SPACE COFFEE còn có không gian rộng rãi và thoáng mát, phù hợp cho bạn tụ tập cùng bạn bè hay làm việc. Hãy đến với THE SPACE COFFEE để có những trải nghiệm thú vị và khác biệt trong mùa hè này. THE SPACE COFFEE - Cà phê không giới hạn!', N'tt00004.jpg')
SET IDENTITY_INSERT [dbo].[tbTinTuc] OFF
GO




SET IDENTITY_INSERT [dbo].[tbQuanTriVien] ON 

INSERT [dbo].[tbQuanTriVien] ([Id], [TenNguoiDung], [MatKhau]) VALUES (1, N'admin', N'8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918')
SET IDENTITY_INSERT [dbo].[tbQuanTriVien] OFF
GO

select * from tbNhomSanPham
delete from tbGioHang

select* from tbGioHang

ALTER TABLE tbGioHang
ALTER COLUMN SoLuong INT NOT NULL;

ALTER TABLE tbGioHang
DROP CONSTRAINT CK__tbGioHang__SoLuo__6754599E;

ALTER TABLE tbGioHang
ALTER COLUMN SoLuong INT NOT NULL;

ALTER TABLE tbGioHang
ADD CONSTRAINT CK_tbGioHang_SoLuong CHECK (SoLuong >= 0);


SELECT 
    cc.name,
    cc.[definition]
FROM sys.check_constraints cc
WHERE cc.name = 'CK__tbHoaDonB__HinhT__06CD04F7';

ALTER TABLE dbo.tbHoaDonBan
DROP CONSTRAINT CK__tbHoaDonB__HinhT__06CD04F7;
GO
[CK__tbHoaDonB__Trang__08B54D69]
ALTER TABLE dbo.tbHoaDonBan
ADD CONSTRAINT CK__tbHoaDonB__HinhT__06CD04F7
CHECK ([HinhThucThanhToan] = N'QR' 
       OR [HinhThucThanhToan] = N'Chuyển khoản' 
       OR [HinhThucThanhToan] = N'Tiền mặt');
GO


SELECT 
    cc.name,
    cc.[definition]
FROM sys.check_constraints cc
WHERE cc.name = '[CK__tbHoaDonB__Trang__08B54D69]';

ALTER TABLE dbo.tbHoaDonBan
DROP CONSTRAINT [CK__tbHoaDonB__Trang__08B54D69];
GO

ALTER TABLE dbo.tbHoaDonBan
ADD CONSTRAINT [CK__tbHoaDonB__Trang__08B54D69]
CHECK ([TrangThai]= N'Hoàn Thành' 
           OR [TrangThai]= N'Đã hủy' 
       OR [TrangThai] = N'Chưa hoàn Thành');
     
GO

SELECT 
    cc.name,
    cc.[definition]
FROM sys.check_constraints cc
WHERE cc.name = '[CK__tbNhanVie__GioiT__5EBF139D]';

ALTER TABLE [dbo].[tbNhanVien]
DROP CONSTRAINT [CK__tbNhanVie__GioiT__5EBF139D];
GO

SELECT MaNhanVien, GioiTinh
FROM tbNhanVien
WHERE GioiTinh NOT IN (N'Nam', N'Nữ');

UPDATE tbNhanVien
SET GioiTinh = N'Nữ'
WHERE HoTen = N'Thùy Linh'
GO


ALTER TABLE tbNhanVien
ADD CONSTRAINT CK_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nữ'));
GO



ALTER TABLE dbo.tbHoaDonBan
ADD CONSTRAINT [CK__tbNhanVie__GioiT__5EBF139D]
CHECK ([TrangThai]= N'Hoàn Thành' 
           OR [TrangThai]= N'Đã hủy' 
       OR [TrangThai] = N'Chưa hoàn Thành');
     
GO

select* from tbNhanVien
select* from tbTaiKhoan


EXEC sp_help 'dbo.tbHoaDonBan';
ALTER TABLE dbo.tbHoaDonBan
ALTER COLUMN MakhachHang INT NOT NULL;
GO

