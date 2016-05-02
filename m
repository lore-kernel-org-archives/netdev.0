From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] i40e: constify i40e_client_ops structure
Date: Mon, 2 May 2016 09:06:53 +0300
Message-ID: <20160502060653.GD10276@leon.nu>
References: <1462104443-30724-1-git-send-email-Julia.Lawall@lip6.fr>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VMt1DrMGOVs3KQwf"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Tatyana Nikolova <tatyana.e.nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Shiraz Saleem <shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Mustafa Ismail <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jesse Brandeburg <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Shannon Nelson <shannon.nelson-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Carolyn Wyborny <carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	John Ronciak <john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Mitch Williams <mitch.a.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1462104443-30724-1-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--VMt1DrMGOVs3KQwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, May 01, 2016 at 02:07:23PM +0200, Julia Lawall wrote:
> The i40e_client_ops structure is never modified, so declare it as const.
>=20
> Done with the help of Coccinelle.
>=20
> Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
>=20

Thanks Julia,

Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--VMt1DrMGOVs3KQwf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXJu59AAoJEORje4g2clinhJoP/2+modFRod8LDdSSNrs1IExN
9QIw0jHlFDck1DyuoBqX5Ag6zNcq5ryNEOhZLI8XO7BgWZDm49A5wfiAU4f/Bjj7
aCTZCNZZvrUGtg8htWoykeSsbWI/SuRPEIokUGFLJBc5eE3haf+PINmM/CRGFBoB
a8eWhOf70F2mge9oKBnqHFBBcu7A0o0NsUCcBK2BrMCWebjYJaBVStStq+TKJAmO
PArwoQDtuT1kiOfzSCAuWZGCPFEiyt6968wq1xCaYrFR81CbGihAdO1xfaFjTPtt
DWnhrsda0CG5R5Zf6/URaDJhZJ+rE0trh4PiaVAsDJPJ2QENKayYaM/DluvIDkxQ
0wz3f96Fs7OJFQvVyRF12TLQZjlBmZYpJS8d0Xd/A+vDg64OmSUTbJPVLAmh1vJ/
w7+csJ3IQaGka2v7yyIJIinafUJO+IsOjv87FbpAq1rbBVDIZsmqX14GLHXThSHC
wsuB7pQEF+/r1dSKgIWPZm1Mrio2l3F8CTpUeg8p7H4AmMrtYIh6hRyHXr6xuUAR
HFKBd6So1Z8+SSNYd+sUqM9MWV+tPvvrd241N6IjmlPYS4OEBr5TGkGrpm8MZpJM
WD0LOl4sPfPDNyvQu8oSyleM3OdKgMpaOR9xyRRz3vIdUGbHnsou6BWju4Rb5VGa
ch/KWbeusn0hKx5HHLEb
=LMvE
-----END PGP SIGNATURE-----

--VMt1DrMGOVs3KQwf--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
