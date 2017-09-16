From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Documentation: networking: fix ASCII art in switchdev.txt
Date: Sat, 16 Sep 2017 23:00:49 +0200
Message-ID: <20170916210049.GA1818@amd>
References: <984d9d24-b558-6308-3252-1c8ddd5eb7c8@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="TB36FDmn/VVEgNH/"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Andreas Schwab <schwab@linux-m68k.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Scott Feldman <sfeldma@gmail.com>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:43099 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750945AbdIPVAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 17:00:51 -0400
Content-Disposition: inline
In-Reply-To: <984d9d24-b558-6308-3252-1c8ddd5eb7c8@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat 2017-09-16 13:10:06, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
>=20
> Fix ASCII art in Documentation/networking/switchdev.txt:
>=20
> Change non-ASCII "spaces" to ASCII spaces.
>=20
> Change 2 erroneous '+' characters in ASCII art to '-' (at the '*'
> characters below):
>=20
> line 32:
>                      +--+----+----+----+-*--+----+---+  +-----+-----+
> line 41:
>                      +--------------+---*------------+
>=20
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Acked-by: Pavel Machek <pavel@ucw.cz>


--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--TB36FDmn/VVEgNH/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlm9kQEACgkQMOfwapXb+vL4+gCeOJcgcdmoPxB/Ug29TfTc8dCh
/LMAoILgEv8OdrVsZPjurs3RXwJOTUS/
=O2iV
-----END PGP SIGNATURE-----

--TB36FDmn/VVEgNH/--
