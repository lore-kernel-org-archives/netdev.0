From: Sebastian Reichel <sre@ring0.de>
Subject: Re: [PATCHv2 0/5] wl1251 device tree support
Date: Mon, 6 Jan 2014 23:57:09 +0100
Message-ID: <20140106225709.GA23070@earth.universe>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
 <1386289336-26704-1-git-send-email-sre@debian.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: Luciano Coelho <luca@coelho.fi>, Tony Lindgren <tony@atomide.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386289336-26704-1-git-send-email-sre@debian.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

> The following patchset adds device tree support to
> the spi variant of the wl1251 driver.
>
> Luciano Coelho (1):
>   wl1251: split wl251 platform data to a separate structure
>=20
> Sebastian Reichel (4):
>   wl1251: move power GPIO handling into the driver
>   wl1251: spi: add vio regulator support
>   wl1251: spi: add device tree support
>   Documentation: dt: wireless: Add wl1251

What's the status of this patchset? Tony prepared an immutable
branch for patches 1+2 [0]. I think the other patches are also ok
(at least there were no more complains from the DT binding
maintainers). It would be nice to have wl1251 DT support in 3.14.

[0] http://www.spinics.net/lists/linux-omap/msg101165.html

-- Sebastian

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBCAAGBQJSyzTEAAoJENju1/PIO/qaoSsP/2A++jAylp/9jdo77OoJl50B
s2Bk6i+g3G/G0ZF5prK/eRRDW6anfU7rzrqNowO0RXkEufRn+vviKaKwXGdCtHmJ
Oa3fi4clbsrFZKvRQjKNdhX8NAoiZsd8wdhXQJXkhS8htenfiGL0Uh7Bs+gVKfyf
1UVsb1nMvBR+MKRdKKNTO59Odm6NCtzZD+WIL0zAzN684vaYTYaV5dNVGsqt+82P
+WPxhqZQPuObRb4HWRm1+HDFWs/zVIXgw6HJPZOeKuSN7bYwNtHstC/s76q7SBBR
m3nkfqOsaAwfiVUVmqla9pac83Gf/2LXdmu8C12Qr4edix1E0KhXTQjVj1MWuR4q
hzqhGVX1GD9pSbWZFxytf0m4Cl52HTvolj7T1zJyKtC95A4fobQQdqEeWoWy98JO
j+iojeGq4bWcMcST7UR7rqK26DKFccm4+E6UQHEFtJDRrsjaojT/qM0UUrPnn5d2
nmseSd9BfC+XGG8Ll6cny1//luCJp9gY4nwg6r/q2mNWaZslTdxKvdmkuP4UsS4m
4DIpB4mTgKtcwfrt3Ba5T4oLuSpiSFmaZPynb3FekInpXhlkQ0731RZ0pAQANhGY
IviRwgCYDU6pawzSXpuwaYW/MQPCpbsGXwQlgSUhKPnVK4YHDpRDjy10e7mFtrbD
119RrTc5DfF/tzCdzboH
=nadp
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--
