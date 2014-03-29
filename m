From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 12/17] i40evf: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:04:47 -0700
Message-ID: <1396119887.2287.34.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <eac4f71e579807056106d6d7e645ee0042e0d4f3.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-d2eF+LHgxGrPkjIsTq5n"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28681 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752554AbaC2TFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:05:08 -0400
In-Reply-To: <eac4f71e579807056106d6d7e645ee0042e0d4f3.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-d2eF+LHgxGrPkjIsTq5n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)

Thanks Francois, I have added your patch to my queue.

--=-d2eF+LHgxGrPkjIsTq5n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNxlPAAoJEOVv75VaS+3Oo3UQAIbAJGd5t6YNReGOPmGvmS0L
E1mGo9FdK8WIP/TkMWyyoqCQJa0mcGweLODENJk0peCxW+20vY2eCfjwGEv2AviV
/bHl4IGv3LYC98w9w6qNI1wnYeBx3h8zbwO8HxzEgUwFrtUHlFIaVrYJeCL6g7oN
eDHfk1lMOo2EFxk/KVx3gFKoAoOkfDF6ZemdI7IyV4kti0xIIDsYZjjyIMr2NCsE
ZxKtOypZms2FT8FiE1+AmVUmMrLgtqYLK7cdO5Ia4T+sByYtzPUJ/qjWNr2j5ySF
cDLgcR9ZakIjIWz1AK3OtxY1qQ2z1n6U7bt/EvhHz+rLTaqtEo/dH8VQKcbnKlRJ
galWrxbcRY+1xS7P7WlSH8k04IdTX4+0p8zm1ndCdaiGVMwsq82rKDD1oBoq1lHA
pt7KjrcUzeb5LJmTow6gvHivCr1MmF1ORHk8htCXshGOAZHMq4aTHo60Qk3lu4Iy
6xF1u1HVuPyYAGZN4lww/NDkWCJr9Pi3B70cbrjklT3LYr3BS7HOfrzyeiu1aJ0d
GzNQBIKC6otO+sIocBqmOR5m/gd6VuYl1LT29UCKal11hbcGk1/rekjIkCWKytsJ
slYCAk8z3JH6IiF6fcuFt8ICw01BpgW3f+0E9Ad67y1otmnvVDrhuF5xEB4xY+de
ylAUuBNpPpjpX+5ssQPz
=D5jx
-----END PGP SIGNATURE-----

--=-d2eF+LHgxGrPkjIsTq5n--
