From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] hostap: proc: Remove unused variable
Date: Tue, 30 Sep 2014 23:56:54 +0100
Message-ID: <20140930225654.GP4273@sirena.org.uk>
References: <1410909415-11661-1-git-send-email-broonie@kernel.org>
 <20140930165626.GD11919@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OwXh6gFRjCd3qPCM"
Cc: Jouni Malinen <j@w1.fi>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140930165626.GD11919-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--OwXh6gFRjCd3qPCM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 30, 2014 at 12:56:26PM -0400, John W. Linville wrote:
> On Tue, Sep 16, 2014 at 04:16:55PM -0700, Mark Brown wrote:

> > Since "hostap: proc: substitute loops by %*phN" (62c5afb8e388) the
> > variable i has been unused in prism2_bss_list_proc_show() so remove it.

> What tree are you using?  In wireless-next, I still see a loop in
> that function using i as an index variable.

This was in -next for whatever day I sent that.

--OwXh6gFRjCd3qPCM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJUKzU1AAoJECTWi3JdVIfQV44H/RGfyC3SpG7H537cvvMztvxw
2tpeunlU7NaU/wHoJMrTYmGSkb2sNaUoWnqHpIwMimxDhSKT9nDWza4p526SAmVH
YItabYObmpGIuSpdd3q3DmwLq3lCEPWM9QyiFPv6HoV1eozU1lfA2185AAIRc5u4
FR108GnKB2NI3lG3oOX4L20CeHbiM5cPiotXRDMtjvjIocuZvcDiOmQywWFkpbtD
2FMrX4lP9LqnLokkXfRYugQkeDd4h2T8V4RiHW0vZBnZC9mswPdzKxTVDHvoNrFF
zyzS2nOHsgCQsq0XoIWEtQtmN42kpsGsgH4RczExNyQpe0sbXkEE8iL/CXKTeK8=
=phRU
-----END PGP SIGNATURE-----

--OwXh6gFRjCd3qPCM--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
