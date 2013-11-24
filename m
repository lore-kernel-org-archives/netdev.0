From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: request to queue "5d0f801 can: c_can: Fix RX message handling, handle
 lost message before EOB" for stable
Date: Sun, 24 Nov 2013 23:15:51 +0100
Message-ID: <52927A97.2060601@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Rr3R45IOP21efj3pEaoXfva9qQJvPjqcm"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	Holger.Bechtold@gmx.net
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Rr3R45IOP21efj3pEaoXfva9qQJvPjqcm
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

usually all relevant patches find their way (from my point of view,
magically :) to the stable trees, however in my last pull request to
net/master, which was merged in

    e9b51a1 Merge branch 'fixes-for-3.12' of
git://gitorious.org/linux-can/linux-can

there were two patches, both had stable on Cc. So far one has been added
to the stable queue, the other:

    5d0f801 can: c_can: Fix RX message handling, handle lost message
before EOB

is missing. Can you please queue, if not happened so far, that patch, too=
?

cheers,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Rr3R45IOP21efj3pEaoXfva9qQJvPjqcm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKSepgACgkQjTAFq1RaXHNHkQCeNGVPjpTxmzgE4iqcwh/MY2H5
+xEAnAuEySsGUXp61uJgTCEyi28Se7Wd
=wOKQ
-----END PGP SIGNATURE-----

--Rr3R45IOP21efj3pEaoXfva9qQJvPjqcm--
