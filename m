From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH] 0/5: eepro driver updates
Date: Thu, 18 Nov 2004 21:40:39 -0200
Message-ID: <20041118234039.GE24080@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9aCKuHbn5v2q3RVc"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--9aCKuHbn5v2q3RVc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,
	these patches fixes some very old issues (I'm scared that
	nobody noticed these before, maybe I'm the last guy who
	still use these cards) and finally implements basic ethtool
	support (promised to Jeff Garzik two years ago :P)

01-eepro-cache_eeprom_values.patch
eepro: cache EEPROM values

02-eepro-module_param.patch
eepro: use module_param macros

03-eepro-ethtool_basic.patch
eepro: basic ethtool support

04-eepro-fix_return_value_in_init.patch
eepro: fix return value in init_module()

05-eepro-fix_autodetect_option.patch
eepro: fix auto-detection option

--=20
Aristeu


--9aCKuHbn5v2q3RVc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBnTL3RRJOudsVYbMRAjDnAJ9Ut09G+1hYcMVlxICqyHT09XAPXACfdBRf
BhMIaSWHXmVPCACK+igzTcA=
=Py/u
-----END PGP SIGNATURE-----

--9aCKuHbn5v2q3RVc--
