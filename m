From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Fwd: RFC 7112 on Implications of Oversized IPv6 Header Chains
Date: Thu, 30 Jan 2014 13:56:38 +0000
Message-ID: <1391090198.4405.57.camel@deadeye.wl.decadent.org.uk>
References: <20140129173044.D475C7FC17B@rfc-editor.org>
	 <52E955A3.7080408@gont.com.ar>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WjRjg8oOmN3UlrjN1nPw"
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36593 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752950AbaA3N44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 08:56:56 -0500
In-Reply-To: <52E955A3.7080408@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WjRjg8oOmN3UlrjN1nPw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-29 at 16:25 -0300, Fernando Gont wrote:
> Folks,
>=20
> FYI. This one has important implications -- it allows stateless
> filtering in IPv6 (otherwise not really possible)
[...]

Still not possible unless you can trust that all hosts behind the
firewall will correctly drop overlapping fragments.

Ben.

--=20
Ben Hutchings
It is a miracle that curiosity survives formal education. - Albert Einstein

--=-WjRjg8oOmN3UlrjN1nPw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUupaFue/yOyVhhEJAQq4yBAAmxEFVimvDRxNlefxlz7a1+YMWYG18X3D
p/K6bvZra9tic8oYviLn+jUI3PaenOVGWpzviMApZWVEzHZupq0qj0uEIbg5wl5g
oZoNe7sMlnkBnru5n1kYAjqv357ngzGXaO+CBJDW97a/G0oquo7thM6jMCH8evOW
ZKTOe9GtZWOGugaV1wdn9Uuv2Zx/9SdKH6vZQVKkfscjLuQemCNHUZuqHALDtUZE
ubiE/AboXbFVdPcBSD9P6RvQ8UgR/a1Uj0MyPLlWlDSmPGP1qgoZxNSpXU+o6C76
eRcILc9wOd15qj0oZc/U/DRqayFZzF3D701RY0zr4yCEKo9+skKgMn48bhOFVFHH
ovZ6fxQZtmsjyh81nefpahbbtMuPzrIgB5u1lcT3nsjfGVV02pXOHXMAKB6BTqvT
NC6wksHtAEG0xe2LfEvSptynGwRC4wQgzZ6olWZJHThECh2E7skILwaaRhIlpXvb
n2st8lgVcA9X+/szM2zHHWcIJHdJo2j6P7eTPPqX3DKpHKlsDSYezAazs9cn6z8e
TLobA8FuOfXWrmMkH9ngJXXWkua8tIKw7Z8JSUWT9CLHGwYTX0hKJVs/fsnfT9TB
SZUxPAqEnGb4R+z7n/S2TTeE9FgOJkTZ123Dwf3PFoLRCWWXZoQBHrjaXLyU43Hl
epNVU03I+oQ=
=SQ6M
-----END PGP SIGNATURE-----

--=-WjRjg8oOmN3UlrjN1nPw--
