From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH 1/1] e1000: unset IFF_UNICAST_FLT on WMware
 82545EM
Date: Mon, 20 Oct 2014 15:25:52 -0700
Message-ID: <1413843952.2256.17.camel@jtkirshe-mobl>
References: <20141020221115.1FC9B480090@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BifuTQxY63JdUpadR1R4"
Cc: netdev@vger.kernel.org, linux.nics@intel.com,
	pv-drivers@vmware.com, fruggeri@arista.com,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141020221115.1FC9B480090@fruggeri-Arora18.sjc.aristanetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-BifuTQxY63JdUpadR1R4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-10-20 at 15:11 -0700, Francesco Ruggeri wrote:
> VMWare's e1000 implementation does not seem to support unicast
> filtering.
> This can be observed by configuring a macvlan interface on eth0 in a
> VM in
> VMWare Fusion 5.0.5, and trying to use that interface instead of eth0.
> Tested on 3.16.
>=20
> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

Thanks Francesco, I will add your patch to my queue.

--=-BifuTQxY63JdUpadR1R4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJURYvwAAoJEOVv75VaS+3OsXsP/0getDYnCLhx2tz8PkUybwFE
ZmWKkaKRmDcE7ov3gT9IjLkDDROCMR8RvdDJH8DHZiv0L9yCP7hOGfl/d9iQY+YG
MvferI8c8do06Yl1Yniw9x8mL6ZZqhKbnDV8bB9V89GgymqK1UOXoOSTWnvFCGGN
gG+UMw94bfHTTj5rvhsObn8zpbDYoLtPGsQfGT+6JpO0Jc0WTuRFBWaMXLxCq5nx
mrN7QEjPhnSmedtm7sU0XdnkDEQwy35R5wzm4+L83iJYrL4SSXgsdjpfcT+D/EGd
L2uGlWIYAxAQOcslhThaAyLImCEwk7i6XUV7e6oLTx+fzB1lwyUGfU/j7qlteo+c
zJMMHdyA9pM3LRHUIQbY9TM709RIetGUTOF4I+ooglxyZkjRTAZ4OcYks8o/Y+wE
ilqFOftLOW6OaglNX9t6UehrH8iU6fpzQftQoS9DeS6mxVl020CDbSf1wWUrDSZs
whfE4OTo1T/MiA8vs5HMbzjn3WwubyBKaF1butgJbqR/tng3Zz+jRgZNLtJ70+OD
YgppzRetqICpXHQC9Vw4uzgW8TylAyOatdOHLs7nb+rVzG7H1Qkxg56bi9r3MSB9
CQ5ZJR2V4CaKRWw659096CZs9pODGNh5F1mQOAnVtIfnuWTYx2fVQiZeix8LD17J
WgI4OXGj16/WDhsBvTRy
=/QHM
-----END PGP SIGNATURE-----

--=-BifuTQxY63JdUpadR1R4--
