From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: r8169
Date: Fri, 11 Dec 2009 12:58:06 +0000
Message-ID: <1260536286.4532.529.camel@localhost>
References: <20091210205821.GX6965@slinky.marshes.co.uk>
	 <4B220E3D.5030502@lastsummer.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-a7Ry6shSCM99uaoifpE0"
Cc: Ian Marsh <mushypea@dominion.net.uk>, netdev@vger.kernel.org
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54153 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754129AbZLKM6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 07:58:05 -0500
In-Reply-To: <4B220E3D.5030502@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-a7Ry6shSCM99uaoifpE0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-12-11 at 10:17 +0100, Franco Fichtner wrote:
[...]
> At work we're also using ubuntu which comes with the r8169 driver,
> and had to deal with network dropouts while trying to benchmark
> heavy loads. This is what the support of our boxes told us:
>=20
> >Please use 8168 instead of 8169. Please see the notice about this
> >important point in May..
> >
> >The situation you observed should be a misjudgment by the Linux Kernel.
> >Driver 8168 is recommended by Realtek. Please use this revision.
>=20
>=20
> No more problems since then. Hope that helps!

Realtek releases separate r8168 and r8169 drivers for controllers
attached to a PCI Express or PCI bus, but they are largely identical.
The in-tree r8169 driver is based on a combination of the two Realtek
drivers.

Ben.

--=20
Ben Hutchings
Kids!  Bringing about Armageddon can be dangerous.  Do not attempt it in
your own home. - Terry Pratchett and Neil Gaiman, `Good Omens'

--=-a7Ry6shSCM99uaoifpE0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASyJB1+e/yOyVhhEJAQKzYw//VRFb3lFWTOkn7URkUpkZcTqw0hMaE5KL
sC1X4VyEAUklCmFe5d6O+Jd0k4cJgy22B/rK3nNiq/Q0fNXoaEmCpazVnL+ZMdEa
cZxs1w9Fruin6SiIFYXDl280leQK4s8fBD/xCLwtWP0xfYjxNlk1xU2q/dqrJ3Na
qtHhv4WCnkI+7kA/YHHvkANYmrYYRHe1rxmPSdiwdupp3MtnxP649RV0wqKGMPWP
fKkV/SkRcddY/LGeYuyXhadCHShKNMUngncgOs/K56MyQiXWHbST4AL+K8OHAAwO
z29Z6qvm5usCxdtUSRj+i1pUE/6eBiSWATxEcUdCLCw1htFXOc/eiNHqJDAIsFBU
aCy+F0/ZjsuIz7OsdmBo8rNzwhH/9jznwsiIdBWmP9vYdvnORLx9rsuo+O1RXjxv
fUTNhQf+ESxMXePo0OOZ9fb/309Izi0aaL/SnE5NvrtyQG/G4VTFiaAcT+uNdaE0
2aRFZp7aa3u0EC8VCHyqZkhsu3uPiZUAFr7rptilr+PeieckuCWj6XF5DwN5C3ch
u3tN/UgPGkFyKPmFYVOONTDkhnUB4c+JtzjVrWZZE7z8gjxKxU9l5ZOYGix1Nb6E
KnB4F2/gVf8lMOykZ6r9uLXm+kW5P+B8H7nqsgc/TE8p/jXbO9o1Yq8sZzuUIQWa
kPYCqldn7w8=
=vpL9
-----END PGP SIGNATURE-----

--=-a7Ry6shSCM99uaoifpE0--
