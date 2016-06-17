From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2] mlx5: only register devlink when ethernet is
 available
Date: Fri, 17 Jun 2016 18:40:42 +0300
Message-ID: <20160617154042.GB5408@leon.nu>
References: <20160615152816.2800830-1-arnd@arndb.de>
 <6330398.ySWGKSmLdn@wuerfel>
 <CALzJLG8BEivMg4h+=FcQ_7QFrZTRhRNsPgEH68WPKfmkguvNqA@mail.gmail.com>
 <51058521.f6SstSCt2o@wuerfel>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2vfFyZRy2guiefOI"
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51058521.f6SstSCt2o@wuerfel>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--2vfFyZRy2guiefOI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 17, 2016 at 05:02:33PM +0200, Arnd Bergmann wrote:
> On Friday, June 17, 2016 5:50:14 PM CEST Saeed Mahameed wrote:
> > On Wed, Jun 15, 2016 at 11:50 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> > > On Wednesday, June 15, 2016 7:04:54 PM CEST Saeed Mahameed wrote:
> > > Ok, I see. It would be nice if the process had a way to avoid build r=
egressions
> > > in linux-next, in particular if you already have a fix by the time a =
patch
> > > that introduces a problem gets added.
> > >
> >=20
> > The reason we added this tree is to get 0-day testing but currently it
> > makes some unwanted noise
> > so we will remove it until we figure it out.
>=20
> I think you can simply ask Fengguang Wu to add your git tree to the list
> of trees he pulls from for the 0-day test bot.

It is not 0-day only, but linux-next too. It works flawlessly for RDMA
topics and Doug receives cleaned and fully tested patches. Sadly enough,
it didn't work well for mlx5 net part.

Till further notice, I removed mlx5 net part (submission queue) from my
tree and from linux-next.

--2vfFyZRy2guiefOI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXZBn6AAoJEORje4g2clinXfYQAMGF80nVGPxbqFcwCIFBwwJk
OOQ7U4Qary0BE3X3aYhiloxDtZQoschtUyutoARpW9o3uqqPgkn9WnCeGx4i4Ny6
I7RkzxCfBgWh0QGCdqog9+O8chj0No7MXrsZoDXHv4HSNQakTMpMu7B+TKFKQeUv
cg7BAcqPAdgBEmvd2scm59CJC+ncHxDuJNZxpADyS4t5YqhhTPxHUVcnbaqYCFZx
ONU/FJZkmc/I2esGnJJ2nmfmrOxwjYFFJMFTzAA/+KPoT/DE88CQ0Ac1MjJdJZC3
ZzP58SkReJQJDBLgIdHB9vx8LAuS2e371M/dSXnhcpDbt0pG48WreKc/JXnM9RhW
yJuUDt17SffyJhhbWmQcwww0G+wQuToHqiEB7ZsdD3+NKOb0sQVL638eAJhdoLAB
oRj1y286d5npoZahMZq+Qahi5tsFQx6vU875C2P5/xDc3z/NjJb49V2pfTaRL6CK
6qpeh12JmBdGYsqUdiDDjHQ5G1lKhN0lRcsHdoiUtA8lO6XU+vEggHF88VDr173B
fcTW4zUGt28HiEqhaBklyFDcY2OiDGQVtDbZltUJqHXp0XGw3/4T93CadIeAbKyk
BCXyquG2Slt/I7cmIP39CYNgKaXGuxECHRT7bap3uAuLgbg1L70gX0q/OMkv0wkf
NiqraMyWtroGCa1lmfqA
=I/DH
-----END PGP SIGNATURE-----

--2vfFyZRy2guiefOI--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
