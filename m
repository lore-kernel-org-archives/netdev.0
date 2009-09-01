From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Network hangs with 2.6.30.5
Date: Tue, 01 Sep 2009 12:20:10 +0100
Message-ID: <1251804010.3464.79.camel@localhost>
References: <7D2F0769-2994-4BB8-B107-DEF2B1346B3A@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-VnKHccCBfgwwcfPOAaJV"
Cc: netdev@vger.kernel.org
To: Clifford Heath <clifford.heath@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50265 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753923AbZIALUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 07:20:12 -0400
In-Reply-To: <7D2F0769-2994-4BB8-B107-DEF2B1346B3A@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VnKHccCBfgwwcfPOAaJV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-09-01 at 19:50 +1000, Clifford Heath wrote:
> I sent this email last Friday, but received no response.
>=20
> As far as I can see, some recent work in the stable
> Linux kernel has broken the TCP stack, at least on my
> (pretty common) hardware. Can anyone confirm that
> they've seen and perhaps fixed similar symptoms, or
> at least tell me what else I need to do to help them
> identify the problem?
>=20
> I recently upgraded my Debian system (a Dell Optiplex GX270) from a =20
> 2.6.16.11 kernel to a 2.6.30.5 one (current stable). My networking is =20
> now misbehaving. If I could revert to an earlier kernel, I would (and =20
> did, it worked), but now I can't because of the glibc version change; =20
> the old kernel panics on startup. This leaves me with a *broken =20
> computer* which I cannot use for my regular work, and cannot afford to =20
> completely re-install.

If you're using the Debian kernel package, please use "reportbug" to
file a bug against it.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-VnKHccCBfgwwcfPOAaJV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBKnQNm79ZNCRIGYgcRApDSAKCf0ymo6majkC87LzhCW0ulOO7GNACglw5E
A13NQci5/74pKsyVFDzZ6YM=
=1Ozb
-----END PGP SIGNATURE-----

--=-VnKHccCBfgwwcfPOAaJV--
