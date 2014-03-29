From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 08/17] ixgbevf: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:03:55 -0700
Message-ID: <1396119835.2287.30.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <c730c47d96b979ff0a578d02cafcc88308159487.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5XLjy3+v+o75xwU13hEA"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20153 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752720AbaC2TEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:04:37 -0400
In-Reply-To: <c730c47d96b979ff0a578d02cafcc88308159487.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5XLjy3+v+o75xwU13hEA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)

Thanks Francois, I have added your patch to my queue.

--=-5XLjy3+v+o75xwU13hEA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNxkbAAoJEOVv75VaS+3OSwoP/jQoVYnHtZj3OZ3PnbEB5Jxb
aJv6YlUnVagiXFDxH7LWQAGMQVQ3jLZ2vepQ6WAPnc6RpgBfDvA9xf9UePPmb6gR
17+ZAapUP/jFo6E20J0fSditeYvJopbTYUx6FiEb2EdE8uVu+H+9Xben+CUlJsoc
JwQ3HD7sGsvg00Ts53Fva70xn/9kWb/Nl+Jp7ft9vTohYO/8/yZe/HXiJcDnRU2F
M6y2/IsQg2r56CVjOUQEm9a6jMt/oCXSZgBLKhkEdJbd+oes6oYT4zfyzlbc3TH1
TWEdOBI5n2irE59/gEqeKAxXfQeujZgcJgfhZrEOQ7HVNxXHqBOArfSYU4Ee8K2a
b5Ds0kP7vPwarqRRbLHLkfSdrUC/H0bgBcnLPuL4X90PLpst8UZnLARE55KUfKsU
Jb6mqOG+uZg9mN7IGhU0RhgaZhCZ+SxY/FDDS/MUUi9TEZwavXf/JyGz142b5QC1
C298Z3cdCP7WF4l9BH+FJwyfrw9PCzEcpcEMXuj62WNwQKtAdrnnO8EvliTX1CdL
SyEonqV+Npjvki/BLReRfHEhDq+9u5c1skmsV97kCL16zftbM29GOSY/omqN7P+C
BAi55yE7K1+vfJNk7sZI6PFKdBt9sWnVopmPTTkp6wf1F9wNxWu9wH9h2jr077pG
LKPba/OQ0vaPpUMKUJ46
=cx5u
-----END PGP SIGNATURE-----

--=-5XLjy3+v+o75xwU13hEA--
