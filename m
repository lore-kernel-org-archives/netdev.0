From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Regression: Wireshark sees no packets in 2.6.24-rc3
Date: Sat, 15 Dec 2007 20:57:52 +0100
Message-ID: <1197748672.16079.59.camel@johannes.berg>
References: <2c0942db0712131746s7da91f2bkf45b3e1ddf16d1f3@mail.gmail.com>
	 <200712150305.02589.rjw@sisk.pl> <47633ECC.3020804@googlemail.com>
	 <2c0942db0712142309v15f79068m8c033180d41b9be@mail.gmail.com>
	 <2c0942db0712150016r149d285bs8f4e1c444e71afea@mail.gmail.com>
	 (sfid-20071215_081641_992849_E96123B3)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ZbAMOyRSv68qhcinASOL"
Cc: Gabriel C <nix.or.die@googlemail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Ray Lee <ray@madrabbit.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762038AbXLOT6R@vger.kernel.org>
In-Reply-To: <2c0942db0712150016r149d285bs8f4e1c444e71afea@mail.gmail.com> (sfid-20071215_081641_992849_E96123B3)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ZbAMOyRSv68qhcinASOL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Sat, 2007-12-15 at 00:16 -0800, Ray Lee wrote:
> On Dec 14, 2007 11:09 PM, Ray Lee <ray@madrabbit.org> wrote:
> > On Dec 14, 2007 6:41 PM, Gabriel C <nix.or.die@googlemail.com> wrote:
> > Correct, absolutely no traffic. So if it works for you, then either
> > it's something that got fixed between -rc3 and -rc5, or something odd
> > when I did a make oldconfig, I suppose. (Or because I'm on an x86-64
> > kernel?) Regardless, -rc5 is currently building, and I'll try it in
> > the morning.
>=20
> -rc5 works great. Really don't know what's different between my -rc3
> and -rc5 builds.

I have an -rc3+wireless bits which also works great wrt.
tcpdump/wireshark.

johannes

--=-ZbAMOyRSv68qhcinASOL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2Qxv6Vg1VMiehFYAQJWbRAAvMVpeMgB5yCHRif90u4ZbYZVEz0OSD4M
KL4gWqQi0M3hk+Ng4j7YyztZCm3u60Vt2H53cHds4RoVehBufCmOTYB9YKYuM1ti
TqlbU/Be9Uo7HWdV2rapYSPyofJ/pBA+bZR6tApcAWCOBdJ1rUcmiiiTmVlBvKHr
YbEu6tgVUNmDXmCY2u7gkrJvvpreQw0z7Xxq3iIjXVNZTOH2EUZo4/keYaAVNnfh
4hrroJQ/cIjTgUbsZKkmmlTtnUxwVGacgIuAToBTZvzAFu4gc2TZSQKlc/Z7/mf5
JLQhIFib/P+pr4sSc4jsFGqu+21i4eWBXDiAGtXaNwwbAVg6VvuFaJ+HNhe6Vtdj
VQi5bCv2fHQdJHbf1GHHu3O9LKm6XE3CmFwXZ2GqgsvFMt74nfC3bAK2TdHAp59A
1//UxYh7g91ESXmqnqEjd5rXibAecGrr2xsZ5f1qWjPcizqEYFU5oqgm9ha6knhc
l4a52hvZfvu9AotKseS8xJCxGEDkk0Jh4yABLucJRmkHAiJHxEOx8GCrLX+gdSmL
7d6Fptjz/TwduAqtF+4gwDq1064TYWbpA758TCCLl1OLELwKoFImg9BwDGWPkpBs
wKSvSSlDZHe+9mGJiNyybwE4h4oDA+CDWQfLV7T7BvTuY0y79C5LZgNJmhBuUQXj
5Zoq560o/Yc=
=vGeI
-----END PGP SIGNATURE-----

--=-ZbAMOyRSv68qhcinASOL--

