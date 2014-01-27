From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: critic on documentation of the network stack
Date: Mon, 27 Jan 2014 00:38:14 +0000
Message-ID: <1390783094.2735.82.camel@deadeye.wl.decadent.org.uk>
References: <20140124032324.GO7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WCbituOa4+iAH5R6F0g3"
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54110 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753257AbaA0AiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 19:38:22 -0500
In-Reply-To: <20140124032324.GO7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WCbituOa4+iAH5R6F0g3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-01-24 at 04:23 +0100, Hannes Frederic Sowa wrote:
> Hello!
>=20
> After net-next is closed I wanted to put the following link here:
>=20
>   <http://linux.slashdot.org/comments.pl?sid=3D4356053&cid=3D45184693>
>=20
> I don't want to start a flamefest or come too close to someone but I
> fear some of the critic is reasonable.  Maybe we can do better (I have
> to admit, I also hate writing documentation, e.g. have not yet send the
> IP_PMTUDISC_INTERFACE man-page patches).
>=20
> I try to start with some constructive discussion:
>=20
> There are some great features in the network stack that some people miss
> because of lack documentation. One possible solution is documentation
> directly in the kernel, but mostly this is just written as a reference
> and the real wonderful stuff is only achieved by putting lots of those
> features correclty together.

I think the reference documentation is also severely lacking.  I have
occasionally filled in documentation of the ethtool API (as kernel-doc
comments) after having to effectively reverse-engineer it from the
implementations.

> Maybe this is the second or third time this was proposed but I'll try
> again: Would it make sense to just start slow and setup a wiki where we
> just throw in the various snippets we use for testing while developing
> patches, maybe with a bit of background information?
[...]

There seems to be an appropriate wiki available:
http://www.linuxfoundation.org/collaborate/workgroups/networking

But developers will need to get into the habit of using it (maybe with
pressure from David Miller).

Ben.

--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.

--=-WCbituOa4+iAH5R6F0g3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuWqdue/yOyVhhEJAQqIgRAAzqsPiqHnWHuItBwK5xFrjIOrAUM4NqJV
DWNaFgcpw4qgMwj+rgNKELRcdNcwsOIuievv+w8LVYLKnH8khgRtgDUSWQH4rFgo
/qOiwKz4QR6wuWyfT7tgvDCpQufDjwmAuAUKcojHlMYn2BGoKQT4ycCfahIu9Qxo
GOEgFRBf6p3cRkgXdmmHlBj4FrbnJSDYJtrtiYoCb3DR5/KmD/ynqy90M6asDT9j
AvvBnleC7V2Ahl6/qF6DURlk1Fes7TUa5k994XGJXd61OrGPhoNnnyWRTwnFHVYk
nGxSWyv/5xfmdstu29u/JkF6tf2LHpHsSaAdyebwDYJWajncwMWtQzs8vgKsIIhU
LO1agi/wxcL0wPxGoigY4YZwgUR3FMcjQOqSSfplSjiybCKDeNmKomQffkH5ifTV
ZEbhxiYPQYtcT/zWRdOrrScE0ciGMJ1BKzs/D8Nhll7aYo+2c2s0rn03+YOL3FsQ
U/MiAWy42MeF/XQndwu/nJ7PhR1DSiTNnW9XyrR3A//8f2P+gN/XzHVBBsbGw8q5
psYC2I0l56WkZMHYFWh2Ihb+2M9FQ9x8kjJSMO8acprfJVPIsAsK0FtpiyWWZj9v
tFDfH8ZomRwkcs1cedu1g/CvVOm+VKxc0Q0BWABA6X0StU8EqFnxDoFx3AmaCfXO
NqpaY9+xC6o=
=g+yR
-----END PGP SIGNATURE-----

--=-WCbituOa4+iAH5R6F0g3--
