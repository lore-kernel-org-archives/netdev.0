From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-02-04
Date: Wed, 04 Feb 2015 14:09:29 +0100
Message-ID: <54D21A09.70101@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="bOBHrLTILhdApsJUfWlqHPC2jcUXEhn7M"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bOBHrLTILhdApsJUfWlqHPC2jcUXEhn7M
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 2 patches for net-next/master.

Nicholas Mc Guire contributes a patch for the janz-ican3 driver to fix
a mismatch in an assignment. Ahmed S. Darwish contributes a patch for
the kvaser_usb driver, to make the driver more robust during the
bus-off handling.

Marc

---

The following changes since commit 7e8acbb69ee2b855288afc61e3794a30e35829=
77:

  Merge branch 'netlabel-next' (2015-02-03 16:22:20 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-3.20-20150204

for you to fetch changes up to a9ca6e13d66042b3ac18d1352b88b7cd0da8fc21:

  can: kvaser_usb: Ignore spurious error events after a busoff (2015-02-0=
4 14:07:03 +0100)

----------------------------------------------------------------
linux-can-next-for-3.20-20150204

----------------------------------------------------------------
Ahmed S. Darwish (1):
      can: kvaser_usb: Ignore spurious error events after a busoff

Nicholas Mc Guire (1):
      can: janz-ican3: fix type mismatch in assignment

 drivers/net/can/janz-ican3.c     |  6 ++----
 drivers/net/can/usb/kvaser_usb.c | 19 ++++++++++---------
 2 files changed, 12 insertions(+), 13 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--bOBHrLTILhdApsJUfWlqHPC2jcUXEhn7M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU0hoNAAoJECte4hHFiupUhY0P/1ulpEdgqnA/i38pY6wpUQXo
m89B0KyoyQdjbjziqGMzZljWyHqoF9LAmCBZTB8UHQZXTeAHCaZTy39pBXfEopE6
+Ks4vhgLugmPPj3Q2v11WMj0mKprGltCPizCbDzajWwwLdrB/8ziYkCYOjhBVhZI
QJWk9FE9AJtnHKbeMofG4cW0i9AsCsYRD+XsgRwNueJLKJ2HirA2yE6Z23IB93kT
fbWcPYmwE2G3L2iDHuzMG5PgkATpEs+f/Mn+DtiR11JH1XjaAG/Ws1d7LUEiAHgT
cY+f60HSNhbOIggrqk49g/Ippy5cajrxA7VgIc6wXspu0OtGNDW4HRdiavA/rmfN
+bdI8VPGS4PAvtnE2UmA12yB5rybtWQLLrVLVigCQcTJNFKLudu7h+BfmGXCzFbX
CEByxRQuXUWcoOsED29E5Y6TpktFDDIVCk7d/LRgQ4ZJmooQ/Wn7cj0bgvNFOjbi
+eqMdNaRx5xIip8veTQ3u0PCC3qyMLMkgXtBOrPWAvKHUXWW75DLmdqboMduL45S
XQ/b8gWa+OP399FqXL/xV8MO3v5LbOSM6djGo0wWBgiv0HtVc3IpvQ0Mgpj1EKAk
XqOyuNBx216Xr+im/wZM8bWq4urfr512+XdAZbcMekZG7XdwVQ3bfFRPcvrD3Z/Y
vOp71fL++tHoTaOzzTvR
=i/hP
-----END PGP SIGNATURE-----

--bOBHrLTILhdApsJUfWlqHPC2jcUXEhn7M--
