From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/7] o80211s: Export dev_seq_{start,stop,next} symbols.
Date: Wed, 31 Oct 2007 13:01:50 +0100
Message-ID: <1193832110.12078.0.camel@johannes.berg>
References: <4727ddda.27ed720a.2444.6daf@mx.google.com>
	 (sfid-20071031_014403_512234_289EF21E)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/dvAvZhLVXoRlsd4t3yk"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Luis Carlos Cobo <luisca-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4727ddda.27ed720a.2444.6daf-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org> (sfid-20071031_014403_512234_289EF21E)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-/dvAvZhLVXoRlsd4t3yk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable



> This patches are being sent just to linux-wireless mailing list. I'm just
> sending this one patch also to netdev since it is not wireless specific.

> +EXPORT_SYMBOL_GPL(dev_seq_start);

A log message that explains why you need this would be good, rather than
a generic introduction.

johannes

--=-/dvAvZhLVXoRlsd4t3yk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARyhuraVg1VMiehFYAQIhGg/8CNZHiFiSz06cmiJxmRTeXY7jMeMVZ57D
yUvktDFmg2bmbfT02W6uM+FEuSloUY9uSrTmwcssDHYaCjVfAQGCRVf0Ak5leAbA
HypGVP/h4XcCbnv7iwuPnHWadUcSoHr0Q7GwONcWjdwE6v0GWhg2h/T+ReshQn6Z
Xl0tHrQcCKDfc3L+4L3969uimFml35JI1ur92uqUOqCSgOfuGw6O89A6REYUmO6R
nEteKEebZq+3fdJwpnD2/MLhdTXSGdRuDKrZvmiScD/ePVD9FQJhzynnWmNngVLi
QGfQRYvBHW6eNIiZCBM1jJm2Zor9AnD8t2A+B5AHEfEnkZW67syOlqIJvEhkPE9+
vV+T9lJ8ZM1pBKp30qXPSI0PkUPhH1T493LbrU0EOOnGP4Gzcgc7dHQHurTCBGEx
QFWSF5O38ObUB8AsxkFiKzXenw7J9BLWB+hU2ybVmaeSH/REGYpjI5hf9W+dBrOT
ncuGg5/vrGx/ujKT5CaPS13hAmjURNFDj/spGpIOhhiljl5hU9ijXtrkO5f2rmxI
Jh4LTD25j5oap8iaZx5ksbf9c7klqXmpT6u4Wlf1wxNMeWpAPmICEqYehhL7Bb/s
AropQ4n7KBqT1xXtCf4uJepxIdp1MkN2iWmQi2m+5SOFr56G271YKfWEBqikzZZj
QEcy5NddlEk=
=Td+l
-----END PGP SIGNATURE-----

--=-/dvAvZhLVXoRlsd4t3yk--
