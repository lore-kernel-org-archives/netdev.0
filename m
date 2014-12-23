From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 07/11] net: igb: convert to timecounter adjtime.
Date: Tue, 23 Dec 2014 13:04:36 -0800
Message-ID: <1419368676.2470.30.camel@jtkirshe-mobl>
References: <cover.1418504883.git.richardcochran@gmail.com>
	 <bb15b44a539ec6da39812229b5fb0718bd6859f0.1418504889.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-u6O/xNMkX1GA7XxnZ2x9"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bb15b44a539ec6da39812229b5fb0718bd6859f0.1418504889.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-u6O/xNMkX1GA7XxnZ2x9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-12-21 at 19:47 +0100, Richard Cochran wrote:
> This patch changes the driver to use the new and improved method
> for adjusting the offset of a timecounter.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/igb/igb_ptp.c |    7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)



--=-u6O/xNMkX1GA7XxnZ2x9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUmdjkAAoJEOVv75VaS+3OecQP/1R/DmPdwPeHxK1aZHnyQWXK
JhmVB9qpZPluMIXHa5KEIPN4wb31HXv7oRG/pVTWcVOVHruz/kglP+42d8zqtB1k
0MaXJoh2qSePOwFQj7NHwjr+SWmPsWjAwdZTuvaJ7D/QcKz1qNlsN4Ou6Qgcvfwi
4BGlxaC5w9sKlDyO6XnozCf6UWQrxVdzCvMo41jWC9/1zhgqRkdYRmOIyT7DzBd7
JeZE6GfzbbIbINlGEHdY2SgeVJnT5+ukC2QyF3QSEmNkpPURvDnrd1cXmJRUBCGd
hb7sjCvLmL+cx4DuM1nsplSYWh+xgJlnw6fSi58cHLjOINy6TxzqWmzFbgeTOsie
AJqsymS077y/mGScwiIsGZU9GUcNeVW2NAf1H3vP97e8Qce5UNFuq5Hr2jro4x8B
dOxIh08T/uAM7mM37bksdxN2ksb+FQCIt3aCRcXdyc0o/1W6gMM+2BLZwYRh7G51
byDAdOMqDQJwrb2iRXX0I+VFMJMCZXwbTENyqlISz7bsW5RgRX0jWHDwLc8V9r8G
7qZnai99RaFFyGehCJ7bcXM5US7OmX/MwSDslaEZyFsHFvmN/7Ozder5uNgX+FHz
pHVVi3f/mlxOpCE8lCkd1DJyklTQGrkOoQXSwqrXpKj/brButjL5HuOrNT/9w7J4
Eao3BChLQNopD+If9xAs
=pPzT
-----END PGP SIGNATURE-----

--=-u6O/xNMkX1GA7XxnZ2x9--
