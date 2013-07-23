From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH] net: sun4i: fix timeout check
Date: Tue, 23 Jul 2013 15:31:14 +0200
Message-ID: <20130723133114.GG10389@lukather>
References: <1374541758-2025-1-git-send-email-emilio@elopez.com.ar>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OFj+1YLvsEfSXdCH"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Emilio =?iso-8859-1?Q?L=F3pez?= <emilio@elopez.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:48808 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932548Ab3GWNbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 09:31:21 -0400
Content-Disposition: inline
In-Reply-To: <1374541758-2025-1-git-send-email-emilio@elopez.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OFj+1YLvsEfSXdCH
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 22, 2013 at 10:09:18PM -0300, Emilio L=F3pez wrote:
> The current timeout check is comparing two constant values, so it won't
> ever detect a timeout. This patch reworks the affected code a bit so it
> has a chance at detecting timeouts correctly.
>=20
> Signed-off-by: Emilio L=F3pez <emilio@elopez.com.ar>

Acked-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--OFj+1YLvsEfSXdCH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJR7oWiAAoJEBx+YmzsjxAgunYQAJZlQMLgwq+A4bpT4q6TmMKy
lq2vKXIuuXSWYqHgQ2xjv4BDo6bJaaxB4CO1nnclsfyth6lv0aOXTVLL6rF3gR33
i2th5M5TPWgM919i5CfLzV1fQu4g0TveC7blUBT8F6J3xzlQXGWZDGDn3q/OhApi
3Lsg7PxAVIHR1/ZYbTs2jmXKZLm1xDidniTCB5NyXmxzxU+4FRNx73YMMVuJijiR
Kqu3x9a97YvmgwH7NNiszFveHq9hZAjRCIMqKgP5kkkxyVN+TFUiX2tCB1ZprbCz
Z+rldsF94Sj9PtliSe9nUCDs9CwkpYweUVld1XaLZkkC7y7uGNA8RG2Uhll3rn28
QZsPJQthI1Wfa/syR8yWCdYqSNbr0P4yH0wUGby7UYJ7YZAebjvA5uKBz3F1ClTo
8mak43HDRFBzbdllcb17bVYzNegFKju9G/hUbPE0nhkc2Puw1+Ed7Mki8qG5Vsls
S/0rV1Hy12Da3m2A5A+lGX58uOscNeVC552ELUShkoXjulTLpDK5D66SF2gYQtHq
1jsqLEZun89hI0sPA7kC/j+1Nq1VxXDfWLBfhBP3fXdNc8ry6wJQRJ1C74I/yfGP
cqhK2WMXMJ4/AK8UILdtF1y1zB/YVsrzhIcmy0HIBJKiSDhts8gnWuVa7n/yO7W2
WxpBF9X/tS9trjEFDAPM
=SGmA
-----END PGP SIGNATURE-----

--OFj+1YLvsEfSXdCH--
