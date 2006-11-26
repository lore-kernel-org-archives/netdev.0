From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: gratuitous arp
Date: Sun, 26 Nov 2006 03:53:03 +0100
Message-ID: <1164509583.30244.7.camel@localhost.localdomain>
References: <Pine.LNX.4.64.0611251526040.8068@twinlark.arctic.org>
	 <4568F663.7090805@superbug.co.uk>
	 <Pine.LNX.4.64.0611251819310.8068@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-PioQB3+XY/B4FTiFd9Ts"
Cc: James Courtier-Dutton <James@superbug.co.uk>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront1.netatonce.net ([217.10.96.36]:59291 "EHLO
	mailfront1.citynet.nu") by vger.kernel.org with ESMTP
	id S967244AbWKZCxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Nov 2006 21:53:06 -0500
To: dean gaudet <dean@arctic.org>
In-Reply-To: <Pine.LNX.4.64.0611251819310.8068@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-PioQB3+XY/B4FTiFd9Ts
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2006-11-25 at 18:31 -0800, dean gaudet wrote:

> but there's no gratuitous arp for any eth0:N aliased interfaces... and th=
e=20
> cisco ARP cache on this ISP router seems to be set to a long timeout.  i=20
> could reach eth0:N from local net, but couldn't get outside local net fro=
m=20
> eth0:N.

Cisco IOS has a default arp timeout of 4 hours.

--=20
/Martin

--=-PioQB3+XY/B4FTiFd9Ts
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFaQGOWm2vlfa207ERAl1xAJ4vdsA7IchWQRMPB5wQ+eP46C1FIACbBUCM
wcqizTLbL8QwHNls0rxBw8M=
=4aoC
-----END PGP SIGNATURE-----

--=-PioQB3+XY/B4FTiFd9Ts--

