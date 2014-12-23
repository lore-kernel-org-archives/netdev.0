From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 08/11] net: ixgbe: convert to timecounter
 adjtime.
Date: Tue, 23 Dec 2014 13:07:19 -0800
Message-ID: <1419368839.2470.32.camel@jtkirshe-mobl>
References: <cover.1418504883.git.richardcochran@gmail.com>
	 <5d83679d541974c164cfc415c0bb171e2b363f16.1418504889.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4HNh19mthAor9npeNqbT"
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
In-Reply-To: <5d83679d541974c164cfc415c0bb171e2b363f16.1418504889.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-4HNh19mthAor9npeNqbT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-12-21 at 19:47 +0100, Richard Cochran wrote:
> This patch changes the driver to use the new and improved method
> for adjusting the offset of a timecounter.
>=20
> Compile tested only.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Just for sanity sake, I will have Phillip test the changes, but there is
no need to hold this up from being committed in the mean time.

> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |   11 +----------
>  1 file changed, 1 insertion(+), 10 deletions(-)



--=-4HNh19mthAor9npeNqbT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUmdmHAAoJEOVv75VaS+3ORbIP/0Pp1dJl2Ik1fRxwpWN1SVD7
5sRN79OINPvPx8iP/yYU2DstZR+ylBHaiqq9GjSqOScVlVBx7/e44LjFn8WSe0si
Te7zJDrL6VFTrNt/xUM6Cwb3wWOcPiym3nY/QRaTKn9YdbVonQe9AchDXW/F+F6l
Gm0oRhjXCGbdAYXDMe6A3mGq5YIE/0ZWfR/K5cjcvqs9FUvH+Z3YQ6ZSMhzsCGVD
12pBoaYH2Oty7A/RR7cUCzcF1rK1zwNxVAHUb9FFrXzYTzm/cOQ7H9MDh3837Myc
UfJ8C3HF5RFiB4eh4aaORTW30BbQRnwsmUhaX/0lh/cUQq0+exPIOO00/VD67z9D
yWEechjKDoB/vVhBgjdNbPQ/FdE+m0W9Qf8xp4KT2+SuXgiJH5DtGxuhGC/yF0IL
hE5nlYQ7ZSWprExjmFyNFM7Hkn8EM8J9YAvw4kjx4yr5wD1HcZrCntLPp3dBK/jM
8Q2TNPomvAfjjiI82YeXjaYULGvKDd6Qzc7cAYEayTWg0K6bcKcJxH8+jMxoSnpj
cTkBhohIGfVXAC4qukzEeUZnyznnhwp8cH5RsjSOTSY58nOsDlV676/86hW8PJeP
wmezQ01M1AFfZbHi4scLT/80acXhEN/3hff+NfZQK2z9xHsuQD825JTbLmoi1PlG
exwDP64GV1TMXnstJZfP
=NvtK
-----END PGP SIGNATURE-----

--=-4HNh19mthAor9npeNqbT--
