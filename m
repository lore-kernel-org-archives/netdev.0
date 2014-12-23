From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 06/11] net: e1000e: convert to timecounter
 adjtime.
Date: Tue, 23 Dec 2014 13:04:18 -0800
Message-ID: <1419368658.2470.29.camel@jtkirshe-mobl>
References: <cover.1418504883.git.richardcochran@gmail.com>
	 <7455b879a8aab91f11c3082c2c8c1dc3ef71b96e.1418504889.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+aW65Ba0NpD5rJXNOB/r"
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53998 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756637AbaLWVEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2014 16:04:20 -0500
In-Reply-To: <7455b879a8aab91f11c3082c2c8c1dc3ef71b96e.1418504889.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+aW65Ba0NpD5rJXNOB/r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-12-21 at 19:47 +0100, Richard Cochran wrote:
> This patch changes the driver to use the new and improved method
> for adjusting the offset of a timecounter.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/e1000e/ptp.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)



--=-+aW65Ba0NpD5rJXNOB/r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUmdjSAAoJEOVv75VaS+3OWxYP/R/eWOd9g524oVqTgb2ke2bW
TAiEUtqwpx+sCWXO64omtZA3vC0sWRWzfRpS6q+NPjtDeCI4npAWPxhjPk4H04Ap
YTJ3AxOzm0uywZjd86OX+oJmGLkC7EsrgqYVaSWlch0pcxHOWqhLZYOFNbT2QnCR
qNI9pm/9jqutJp3ppZOt1Z33NJ4aTsUZE/6q8LlxvcltpvPWUva0jUg5txPwI0IQ
bjHS6jHhjoZyBdC57+sbBnTRmIZcbXd4nQbjNVPnamYX6VLuw1hpg5Wg75bbIzxy
bdMe/8Cef9Rkm/LzlhcOA1rfI5Xg7bZGBeqv3LUQ6if2D64zPVDzIbjJ+0eW8S55
2vLRWEUBs0lkXHs8D3giSm73BMEiK1jK3DXEvAaN+6Lmc/uC1fNJyYjgHW0lLSPB
B1I4uj/+oEN8gLh7f51A8M5M8DdTk1ak6l2as6bfePoyTtZEUMPsfub0qAx7oz6r
OF5H6PGU7Rc2DFDXqEfvQqK7j7ey4TE/lFEWmj108wQaDZbOCQXqxM1L0jQ8MmIy
EKbZmWflQJN1CNRD2fxH8/liHmHktRhuOETCQ723FPn9Je4yjRWlDY0NgsPH6vOl
+9z82vDaTKIml0FUbZ8l/KNNTzAmRX7WAAVCqSyMf98y3oimISNMjjISxewKia0l
uAA8Arthm+EqO0DFlvit
=f+2h
-----END PGP SIGNATURE-----

--=-+aW65Ba0NpD5rJXNOB/r--
