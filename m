From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: isdn: pcbit: another off-by-one issue?
Date: Tue, 30 Jun 2015 23:46:08 +0200
Message-ID: <55930E20.1030202@imap.cc>
References: <87381zqr4y.fsf@rasmusvillemoes.dk>	 <20150611075852.GE11734@mwanda> <87mw06egrg.fsf@rasmusvillemoes.dk> <1434023060.2271.105.camel@x220>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="9mtBpPrSDtuNONBoMC2nfUJUpkxriaceb"
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434023060.2271.105.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9mtBpPrSDtuNONBoMC2nfUJUpkxriaceb
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 11.06.2015 um 13:44 schrieb Paul Bolle:
> Besides, it is, apparently, an I4L driver. (Though there's a CAPI part
> too. I need to check how that fits into the picture.)

If I read the code correctly it talks I4L to the kernel but CAPI to the
card. This would have been a natural candidate for porting to the kernel
CAPI interface, had anyone bothered. Which reinforces the impression
that no-one is using this anymore.

Note also that the FTP URL mentioned in Documentation/isdn/README.pcbit
doesn't exist anymore.

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)


--9mtBpPrSDtuNONBoMC2nfUJUpkxriaceb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVkw4tAAoJEFPuqx0v+F+qye8H/3obozwc6t9Uqhd9nCkmF9es
tOz1YhAZMiAgZj69PxnyWz2/5JYUdL3aY7YUQd2pDyk6DUMLRLjCloRCwzgmsSrb
N3Ysa61MNfGdKybubolBlHOXdolEfHxC3cAEWAApm020FDg9B87nV+YGjtQa9S2x
uju77JzocI58azN10VruiREq8K+dWaImYL3M6HCGdpZ3Eh977ndwX3vcGtYBKDcA
bRbPNI9gnjZAk+0pd08e2MCDBOK7vNaYkIuP5kunKFl5/+XVxE0rsme/PpQc1Gs3
yhQvBwg3xIsGFsBGTCLIBrLLDgXrDsd1DG+zD2KU/In8T3y3jU1SCyJi1TKD97A=
=ra4Z
-----END PGP SIGNATURE-----

--9mtBpPrSDtuNONBoMC2nfUJUpkxriaceb--
