From: Felipe Balbi <balbi@ti.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Fri, 12 Dec 2014 11:32:10 -0600
Message-ID: <20141212173210.GI7549@saruman>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
 <20141204165609.GJ18045@saruman>
 <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
 <20141210171724.GI4602@saruman>
 <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
 <20141210210234.GN4602@saruman>
 <CAGm1_ktYg4iDgK7jyi5etSVup61LdookkV+SaQZOpLb6M=y7hA@mail.gmail.com>
 <CAGm1_kuaqXrU4zhNUZeY85+OeXHApSUDjJdsXcyBdvHTNhLCmQ@mail.gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FK65GREB+Evh/hTL"
Cc: Felipe Balbi <balbi@ti.com>, netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:58255 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030953AbaLLRcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 12:32:17 -0500
Content-Disposition: inline
In-Reply-To: <CAGm1_kuaqXrU4zhNUZeY85+OeXHApSUDjJdsXcyBdvHTNhLCmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--FK65GREB+Evh/hTL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Dec 12, 2014 at 01:00:51PM +0100, Yegor Yefremov wrote:
> U-Boot version: 2014.07
> Kernel config is omap2plus with enabled USB
>=20
> # cat /proc/version
> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
> Mon Dec 8 22:47:43 CET 2014

Wasn't GCC 4.8.x total crap for building ARM kernels ? IIRC it was even
blacklisted. Can you try with 4.9.x just to make sure ?

I'll try to run your test case here once i'm back from vacations.

--=20
balbi

--FK65GREB+Evh/hTL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUiyaaAAoJEIaOsuA1yqREAzEP/0Z9O1lqwDKwpekze/XvWkZc
42qtIvVl9mrPstSS/5PimPdxQ7L/wWj7cIPEGOKWKd93ZVFvGzI5NG0l5jjnknkr
HvfPakeyDc3TpbFlpOghuZNHxwfQ8rHL90aVpnsWCqUf10ipA+je1Xb8bbpjltAe
y8IUnceiPb4eZ7W97lZZrl2XSuxDihWOQ06nW4+YPsXCHWU6tYjDY93OPT7++cK4
dTdRHqScrB+orPLtRTPA7na5iET+1XnMO4iNVYjlkPHgVRLl4FBfrGvIJO1B51xA
BqfIsootgKnYt1kviUoXnIYtLCfnS+8+BgzZUgySKO80LXYq+Hudj0br2GR2SVB3
DJrjrhhDCw+9VbYhnTgqAylisGk49OTj9+AHNFNGVdes132uH8qpRaIpVbrYZ1b2
Qwv+FIcL308EQr2wVutdDDFmgl2siJbcf9BMueHqKaueeW+vWi6pfpgUAK/wH/uc
hM+yrklASskrwja2xwyf+r/pyftAiI733RBww4Hwt32/aauBGrtnVoig6owrs+R3
/e3oNyLGX/hedh9JdessgsPYC8Tc7mE4h5fnDRgFoYfce/OuWSoYx+BhmpurATE4
NIXfx0LgigAtG3e85DGWQYOPzmFvxMV8Ws2QRIr9ZvRboG66FtAqdAqFfAp1RmkE
1L52zyUVkl3p0llpQm7M
=Gwb8
-----END PGP SIGNATURE-----

--FK65GREB+Evh/hTL--
