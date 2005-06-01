From: Lukasz Stelmach <stlman@poczta.fm>
Subject: Driver for MCS7780 USB-IrDA bridge chip
Date: Wed, 01 Jun 2005 03:11:10 +0200
Message-ID: <429D0B2E.3010309@poczta.fm>
References: <42943CB5.50400@poczta.fm>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD2F69C3CAEA5D906B4E0F3DA"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <42943CB5.50400@poczta.fm>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD2F69C3CAEA5D906B4E0F3DA
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable

Greetings Everyone.

Greg told me that you (the list) might be interested in this so I
should send the announcement to you.

The new, shiny 0.2alpha.3 release is ready to test it, smash it and blow
it off ;-)

The major improvement is support for other SIR speeds: 2400 through
115200 bps. Well I think they will work but frankly speaking I haven't
tested them because my Handspring always negotiates the highest rate.

I am sure there is quite a lot of bugs left so *please* test it as much
as you can. I am realy convinced that performance may be a really big
problem so I will appreciate any comments on the design.

Source tarball is available at:

http://www.ee.pw.edu.pl/~stelmacl/mcs7780-0.2alpha.3.tar.bz2
http://www.ee.pw.edu.pl/~stelmacl/mcs7780-0.2alpha.3.tar.bz2.asc (sig)

or

http://stlman.fm.interia.pl/mcs7780-0.2alpha.3.tar.bz2
http://stlman.fm.interia.pl/mcs7780-0.2alpha.3.tar.bz2.asc (sig)

To answer your question: I will make a patch but let me first be sure it
is usable and at least beta-stable. You can help ;-)

This is the announcement of the 0.1alpha.1 version:
http://lkml.org/lkml/2005/5/25/47


Always yours.
--=20
By=B3o mi bardzo mi=B3o.                    Trzecia pospolita kl=EAska, [=
=2E..]
>=A3ukasz<                      Ju=BF nie katolicka lecz z=B3odziejska.  =
(c)PP






--------------enigD2F69C3CAEA5D906B4E0F3DA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFCnQsuNdzY8sm9K9wRAlRBAJ0Vpuw04ROL/5KjfYpBwDpJYrEn0wCfQUyZ
DMqTjLmN1wgpJsPSujRmZDE=
=7yn/
-----END PGP SIGNATURE-----

--------------enigD2F69C3CAEA5D906B4E0F3DA--
