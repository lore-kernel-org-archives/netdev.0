From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH] netdev/fec.c: add phylib supporting to enable carrier
	detection
Date: Fri, 26 Mar 2010 15:47:51 +0100
Message-ID: <20100326144751.GA22937@pengutronix.de>
References: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="envbJBWh7q8WU6mo"
Cc: s.hauer@pengutronix.de, gerg@uclinux.org,
	amit.kucheria@canonical.com, netdev@vger.kernel.org,
	kernel-team@lists.ubuntu.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Bryan Wu <bryan.wu@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 26, 2010 at 05:50:52PM +0800, Bryan Wu wrote:
> BugLink: http://bugs.launchpad.net/bugs/457878
>=20
>  - removed old MII phy control code
>  - add phylib supporting
>  - add ethtool interface to make user space NetworkManager works
>=20
> Tested on Freescale i.MX51 Babbage board.
>=20
> This patch is based on a patch from Frederic Rodo <fred.rodo@gmail.com>
>=20
> Cc: Frederic Rodo <fred.rodo@gmail.com>
> Signed-off-by: Bryan Wu <bryan.wu@canonical.com>

Great, will test it soon.

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--envbJBWh7q8WU6mo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkusyRcACgkQD27XaX1/VRus2ACgrco/6/7oqZa1FsTGNvfeCXjX
26wAoLmbV0eKxR+MsP1y46q5UPRGvBxv
=zAg0
-----END PGP SIGNATURE-----

--envbJBWh7q8WU6mo--
