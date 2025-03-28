using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace Web_CuaHangCafe.Models;

[PrimaryKey("MaKhachHang", "MaSanPham")]
[Table("tbGioHang")]
public partial class TbGioHang
{
    [Key]
    public int MaKhachHang { get; set; }

    [Key]
    public int MaSanPham { get; set; }

    [Column(TypeName = "decimal(18, 2)")]
    public decimal SoLuong { get; set; }

    [ForeignKey("MaKhachHang")]
    [InverseProperty("TbGioHangs")]
    public virtual TbKhachHang MaKhachHangNavigation { get; set; } = null!;

    [ForeignKey("MaSanPham")]
    [InverseProperty("TbGioHangs")]
    public virtual TbSanPham MaSanPhamNavigation { get; set; } = null!;
}
