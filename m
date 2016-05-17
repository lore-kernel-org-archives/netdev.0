From: Tyler Hicks <tyhicks@canonical.com>
Subject: Re: [PATCH 0/2] Quiet noisy LSM denial when accessing net sysctl
Date: Tue, 17 May 2016 09:13:47 -0500
Message-ID: <573B271B.30202@canonical.com>
References: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
 <20160508.235620.333454221783238471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="FdWqHrkVOXAXf5jwedm8Jobtrgsw1emcq"
Cc: David Miller <davem@davemloft.net>,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, serge.hallyn@canonical.com
To: jmorris@namei.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160508.235620.333454221783238471.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FdWqHrkVOXAXf5jwedm8Jobtrgsw1emcq
Content-Type: multipart/mixed; boundary="NqAuU6cvBqmdN3J9Ua2d0L5B6K1ucmUA6"
From: Tyler Hicks <tyhicks@canonical.com>
To: jmorris@namei.org
Cc: David Miller <davem@davemloft.net>,
 linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, serge.hallyn@canonical.com
Message-ID: <573B271B.30202@canonical.com>
Subject: Re: [PATCH 0/2] Quiet noisy LSM denial when accessing net sysctl
References: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
 <20160508.235620.333454221783238471.davem@davemloft.net>
In-Reply-To: <20160508.235620.333454221783238471.davem@davemloft.net>

--NqAuU6cvBqmdN3J9Ua2d0L5B6K1ucmUA6
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/08/2016 10:56 PM, David Miller wrote:
> From: Tyler Hicks <tyhicks@canonical.com>
> Date: Fri,  6 May 2016 18:04:12 -0500
>=20
>> This pair of patches does away with what I believe is a useless denial=

>> audit message when a privileged process initially accesses a net sysct=
l.
>=20
> The LSM folks can apply this if they agree with you.

Hi James - Could you pick up these two bug fix patches? Thanks!

Tyler



--NqAuU6cvBqmdN3J9Ua2d0L5B6K1ucmUA6--

--FdWqHrkVOXAXf5jwedm8Jobtrgsw1emcq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJXOycgAAoJENaSAD2qAscK8kEP/R2mBIi8zM6j1OsMAM0X56CP
SK+IeXqLAfTIufpNXWL+81elJgUj9umLCQRzmu5b5AHgJhIqz8+G6gZIaBqPAop1
qyRe9N4YmBP5Zx0J4pcVNyxcmux41HcicJS2ADXk8mXsTHVsEN36KMpOEX9iRFVa
YOVAl1KYihJt2dJhYAfx6tJ/cH+0ZvVjHG2aUy/DKLL+2wrsy0epHgSLQsp4Tkor
gMvX1qJStJh7MhbS/DabOe4mI8dxVJEpkuD+IKnH2pcbPcfaZIw9+hnzWDMgCvmU
NDXBdHJTW5EwiqSYb1BtLyuvsMfQ0dRsTmeuWkCMzW+X9XzW7TWKxovCZe6U26ha
1Uf+4LnXdh+MqTEYd4v0jHsrJDhQv/O0syaJ/zF1jJUKYx7nSIa26mzAOmQu7X58
Ls/zABOvyHPLKRYeAx7N3xJD3fT9VfRSgi3FXvua4TgsmRN6I2Flu7aZLxaxchSH
GunDIq9fkUlmvEHaIPM5f9gX6hGmM73MhHq6YANFinps2EwwvIJK4wTw1C0buBzs
rDx5wNjKUtfugxOtJGRQ39NRXjLjwO3xSUyMnNSHnBgqsWYZ2Zjb7ooVXUHULp1k
RytWN0wianIK4O5SIkpdu5t/C1tJfjulq+XuFGGOoXNosB+d/z5V8MubGnluYkYa
RdUjvRp6Lj2E13MCODWq
=hxRz
-----END PGP SIGNATURE-----

--FdWqHrkVOXAXf5jwedm8Jobtrgsw1emcq--
