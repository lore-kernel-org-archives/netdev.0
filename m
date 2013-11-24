From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: request to queue "5d0f801 can: c_can: Fix RX message handling, handle
 lost message before EOB" for stable
Date: Sun, 24 Nov 2013 23:58:08 +0100
Message-ID: <52928480.8010803@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="mRtI8a6M2PLHPablM0mCG00U1btHwb3Fo"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	Holger.Bechtold@gmx.net, Linux Netdev List <netdev@vger.kernel.org>
To: stable@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mRtI8a6M2PLHPablM0mCG00U1btHwb3Fo
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello Greg,

can you please queue

    5d0f801 can: c_can: Fix RX message handling, handle lost message befo=
re EOB

for the stable trees.

This patch was part of a two-patches pull request to David's net/master
tree, which was merged in:

    e9b51a1 Merge branch 'fixes-for-3.12' of git://gitorious.org/linux-ca=
n/linux-can

One patch has already been queued, the other not.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |




--mRtI8a6M2PLHPablM0mCG00U1btHwb3Fo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKShIAACgkQjTAFq1RaXHMcfwCfRMXNFT1XGU+EwUC7esYQja5F
JfYAoJgsFoZpVaxlSi7F6YAzMwhR/oGW
=mbrn
-----END PGP SIGNATURE-----

--mRtI8a6M2PLHPablM0mCG00U1btHwb3Fo--
