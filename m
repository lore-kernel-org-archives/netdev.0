From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store
 methods
Date: Thu, 1 Oct 2015 12:23:40 -0500
Message-ID: <20151001172340.GF4469@saruman.tx.rr.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-3-git-send-email-hch@lst.de>
 <20150927154752.GC16364@saruman.tx.rr.com>
 <20150928133328.GA30453@lst.de>
Reply-To: <balbi-l0cyMroinI0@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KR/qxknboQ7+Tpez"
Cc: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>, Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pratyush Anand <pratyush.anand-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<ocfs2-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150928133328.GA30453-jcswGhMUV9g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--KR/qxknboQ7+Tpez
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Sep 28, 2015 at 03:33:28PM +0200, Christoph Hellwig wrote:
> The Subject line is part of the commit log.  If you have a useful

heh

> suggestion for improving the logs please feel free to suggest it.

how about explaining why you want per-attribute show/store methods ?

--=20
balbi

--KR/qxknboQ7+Tpez
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWDWwcAAoJEIaOsuA1yqREApsP/37MI4kN77BkL1aS0LqLVLhD
cdLeKtaFz2DCoh7mBHX5csMPCmtV3c1RYFcLdqNhGCu9NE/Ea4PFYKTIBLZmxBGk
1K3nt7E163PF1PpIni1+OVtd6ebG9bLLeGmsWyg3EUZVFI25LuywT8tQ6lrjAJDA
TZ0i2UAnccZ4qxJNE4k1GlVW//3mMm9Hf9f6SJ9Zss9/JhzC6KpTe9fzLhgRd2gx
waWR1mQfl2mOU/BclklQk41i1R0j7W/Iw+UgifsCvWWhGuKH+BiVqGMoUM0SDtTt
f1GHTYq6lu+UcBC4dXT+7I2G/Lr1LxuxXZyVEvR1FrwzDD+cFZN1hw4NJ2qEDgKy
RGkxmYmMi+I7roCoa7GsJ/CP3t2AXrh8adE2XlAERBYpreZjHjHbH353kfUjhjT5
94Z3990DeCR5d+5XjMK+Be1BSGrKbA6Qwe58RUsfgt92k7PloDQmxRzF821y1SBr
F3fLAfdzk0T/kIjuddfDVOr2vgfZcocpURFOZU9W+IWTlHe+suw1Ma72EheXv30/
Kdrc9gdHzhgGk96NicDSIGWFKnjLTKZAmo92QW8cH24MkgA9FOg9vtczJGi5g8QL
HkDRkScSWCBwE1akcNlczwEcHFyaKDz/SUdq/YexGdwT+Gamiu1nJul6HTMoyARz
tcPvVSCO/PUuIHZ5Iexn
=H4fV
-----END PGP SIGNATURE-----

--KR/qxknboQ7+Tpez--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
