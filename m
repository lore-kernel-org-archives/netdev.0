From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 14:10:12 +0200
Message-ID: <1149682213.3999.14.camel@johannes>
References: <4485D66B.7080108@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CMTUMt7d4KnUr+muv3jX"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:39120 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932219AbWFGMK1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 08:10:27 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <4485D66B.7080108@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CMTUMt7d4KnUr+muv3jX
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2006-06-06 at 14:24 -0500, Larry Finger wrote:
> Jun  6 13:34:10 larrylap kernel: SoftMAC: generic IE set to=20
> ffffffdd160050fffffff20101000050fffffff20201000050fffffff20201000050fffff=
ff202

> Why does SoftMAC set a generic IE rather than get one from wpa_supplicant=
? I would appreciate help=20
> with this problem.

generic IE is what the wext is called, it is the IE that wpa_supplicant
sets. Not sure what's going on though, I know next to nothing about wpa.

johannes

--=-CMTUMt7d4KnUr+muv3jX
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARIbCIaVg1VMiehFYAQIDPw/+I3X0XYV6wwbTdBYDer3Ia+rNYyu6tbGX
mJ0hNLcuFJx4SCJeUs7PDlqhTvq1vQ5U4+bwQEVShHUQHL4tPyBG7HcLtNgRBbns
NdzJ0sfeFJcmJEB/bKNbyOsfzenOqlXK/xeKG+kMbQp5sfswSpTi52EqQNcKIB4c
XSRfmlKAS/2D0DaLzQwHRvUoYKKiPi72e4PHi8E75WHVcoeg6OCkHCP0e4aWJTSG
ZNQVxzbQviDFQGJQsr1/GzPAgU6Rj1k5RMTKMejup4lYl04NwCYPTZ+yKxdpWekZ
wJkNlDuThJW7h2hkAhSgiddENV/UEh3H1wZsQUMRg7Ie2XL78umW08m87S2vAqRJ
Ev0ie2KS9Kqv7fLzuGjtM3GJTTNuoBzswSnOiw/hXJv9D79YNegpPdyr423hGRuj
PvYk1h81paeYOZ+coJ7kK+IlAFqgfvqQiGFo/DFamVokYtaB0sHlwGd4HfrUNkP+
TseBst1+0+9cLU5eX4wdTbOpeUtNqQkWtNIvW9GpDzAwbeV1znhlfuA2Eb4g39p0
yv9biHv3x4cFZ9xJaz46yMALXQ8cIiWsRQa8D9N8uWTYKL2W1tC3UKPgougosj7R
qTEmr5YcpnOCv3l7Pk6+8/INM5jBta0FGQpTjJ28sGqqkneEf0t/YBlClTPXkm2b
jJrwo3uJQs8=
=XV+7
-----END PGP SIGNATURE-----

--=-CMTUMt7d4KnUr+muv3jX--

