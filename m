From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 0/4] igb: auxiliary PHC functions for the i210.
Date: Mon, 17 Nov 2014 15:15:18 -0800
Message-ID: <1416266118.2983.3.camel@jtkirshe-mobl.jf.intel.com>
References: <cover.1416265321.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6WQeffX+6PdBSP7XQot2"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	bruce.w.allan@intel.com, Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15269 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612AbaKQXPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 18:15:25 -0500
In-Reply-To: <cover.1416265321.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6WQeffX+6PdBSP7XQot2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-18 at 00:06 +0100, Richard Cochran wrote:
> This patch series adds three features: time stamping external events,
> producing a periodic output signal, and an internal PPS event. The
> i210 PCIe card has a 6 pin header with SDP0-3, making it easy to try
> out this new functionality.
>=20
> An earlier version of this series was posted way back in May, 2013,
> but that version lacked a good way to assign functions to the pins. In
> the mean time, the PHC core has a standard method to configure the
> pins, and this series makes use of it.
>=20
> Thanks,
> Richard
>=20
> Richard Cochran (4):
>   igb: refactor time sync interrupt handling
>   igb: do not clobber the TSAUXC bits on reset.
>   igb: enable internal PPS for the i210.
>   igb: enable auxiliary PHC functions for the i210.

Thanks Richard, I have added your series of igb patches to my queue.

--=-6WQeffX+6PdBSP7XQot2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUaoGHAAoJEOVv75VaS+3OjZ0P/1TFt++zXoM/nw0Qj+dTFZmO
GGvGmhzo3Pe2UMSwT25/Fr/lybxU+ukIJpt/1f6/BbWaaCT4Q3/H/A/EYXnmzIk5
iX894wZJyiZIbAQycpl4LZ/3kU/V6XFJ8+Owayu7g6cDGmQPoXdQSBO3M4dA9vQY
wj/LgkB7f7nq6NWW1ux05hXdUKKzqFGJn8YgEE9OrfpbfaixRvuOQ8YPw01upPbG
mw5ttyTSwro4DUF+4nTL6MtahmhyKDq2pVu1R4uQ82oJdK1/cw6k4mQu6fjCUxLY
3JaWqdJPUY3YS3q85v+5fNnvPS51EaB0JdbOGr2/5aRRHd4Esc5wamJ6x+x5O77X
cMpx8KBiWlUlHKKrTOI8KDrGTTgMn/HTULFoJm00HtOScZQFUfmQ5kkHj06Ee4zW
T0nvfKfZteNe8gFu8Fp3EWCz7SzWDtzRBY61U6Piytqa5QrP00zfAm5QnPxvESj0
rQLn+dTrqlwQ7nKiftpIvDhcQiRoOUFVMLnE0MAyAUda7gzJlDYoSQ2Fp1w8Bdnc
48gWTgISiajA5OqYfPf5NBweTMR0rP/U11Pr/FN6UAlUDQ/eJITyoN9vSQo3KNNt
RSt8bB6Zqlz6DIXIHp9+zwZ4m9SjwKsiJwdRrtJH9rLVwSPTM4aftHm1b/fSOUAI
xiqoba7w2E4ntKVZnmzK
=aRKV
-----END PGP SIGNATURE-----

--=-6WQeffX+6PdBSP7XQot2--
