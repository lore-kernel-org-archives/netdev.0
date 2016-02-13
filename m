From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH net-next v8 01/19] lib/bitmap.c: conversion routines
 to/from u32 array
Date: Sat, 13 Feb 2016 01:04:32 +0000
Message-ID: <1455325472.2801.73.camel@decadent.org.uk>
References: <1455064168-5102-1-git-send-email-ddecotig@gmail.com>
	 <1455064168-5102-2-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SoZ15GJO7MTtLdasxqMl"
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Ed Swierk <eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org>,
	Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
To: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455064168-5102-2-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-SoZ15GJO7MTtLdasxqMl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-09 at 16:29 -0800, David Decotigny wrote:
> From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
>=20
> Aimed at transferring bitmaps to/from user-space in a 32/64-bit agnostic
> way.
>=20
> Tested:
> =C2=A0 unit tests (next patch) on qemu i386, x86_64, ppc, ppc64 BE and LE=
,
> =C2=A0 ARM.
>=20
> Signed-off-by: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>

Reviewed-by: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>

[...]

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
--=-SoZ15GJO7MTtLdasxqMl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVr6BIOe/yOyVhhEJAQqiyQ/8D8DlXKxG4ASRdvf3Gte7dXZDg8Bv/oQG
M8Cc6bJjkqAPaIvUBuSEQNYc0kVWoRE0B4nz0hN8tb/OKHW7lw6JOvButoU7eaTS
05tpY35akzhIawmy7E9h5dk+6f0dPAwPdAOyHqN0nZPfpxPr9PntByoW/yRiXsW7
+3pKi8OAi49gdMJiC+0EsfpD6X+t/hw/sg7iU0+YwQjhaHhU1B+Mba8SFq9Vxl+q
dZe2MvZbSn1UwhDbnKK5WWrcLJgSg2OVb6WyuYx0b/ntjnC57mFt4UPd8suwFkXa
mooS9XQxaTILYNrDBBpHXs+l4ZE6WAIlqRTQKWe3sImfdYqsvG0aclPHQgtNY6He
CGIudsz/6x9mrhe48aY+L961XHJNDZpGb665qK6Qvw/u0VTW8xw0yD+mMKbza6Pn
g9VwRz+VBET1/ZZW3BPBziyvW4W0GS5Jsi7g2QxaVugBQ6Oc5Qkronx1/GQCXS1W
vfU/vzRnyTkZrZOMg5o4uUcM/2RspQiznc+KpstRn7SgIcklBPQ76ArSfaWdD+i3
UlkrJUih+OAHFlsCyre6jGd9ThnYyuNDvXA7kVzAgT//Yhj01ynu0YgVr7YJ7PtY
OTyEQjy1U89EOBsRlwvdV+zexnbrpwe5bqSjMSXrdXAfKXq8H+uvaRv0XlydS1ZO
0uU79RpTMaI=
=tBPL
-----END PGP SIGNATURE-----

--=-SoZ15GJO7MTtLdasxqMl--
