From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 06/17] ixgbvf: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:03:30 -0700
Message-ID: <1396119810.2287.28.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <3c17d6be148052aa3d3dcc31197e833fa5c20b5b.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2z0ZshhSuwjoZybveNnG"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40994 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752450AbaC2TDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:03:31 -0400
In-Reply-To: <3c17d6be148052aa3d3dcc31197e833fa5c20b5b.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2z0ZshhSuwjoZybveNnG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c | 16 +++++++---------
>  1 file changed, 7 insertions(+), 9 deletions(-)

Thanks Francois, I have added your patch to my queue.

--=-2z0ZshhSuwjoZybveNnG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNxkCAAoJEOVv75VaS+3OpbsP/17BnGHb3CSe/tUXNBGBsosI
Iu//nLi8FxufeI6ReFbfjYTYU1EFIHuB214LlHKnqAfsWAnnAeUghaHyv7ffugAP
wP8eXNS9XDLkfy3hDlNnztI9zakUjCGNK+b3jqmRihOO14YF2ycx0MNqUfoEj/Vu
/ymI5k0x6Idbbr9+GRelOd3Y/jxsGcPE3vP5dSrKIPCaFXEwUN4i6ws6RL0JVtm1
IC0u3uCxFKMqndfAxp+94h9gWFckw+GRwJeDYirTfS6gdn4egP4MojJczUo9SbSr
orwy4zF8e32Xt/PXds2sd5xggyi3HL4kDhHo4g8iUutYMGHkUrMQm0jMtx5cE36B
FtzueOmsCXf+I2/K+0zUb9zZq7dxhd5OP/gCcPrIow+JgxqOuVCavMbkhXd9SAMn
Ueo3epFS13mQQocqrXAI5AlVPXVWhn/JPmqS3zZ2ITV9VJs9PL+rlbX6w12Z4L0e
3CEN6FlV8grdoj6wDCwtDuUjmkZ/mVJmxJGYD1cI1Q57mMezOBDQFEA0PzaUS6hr
fpUPd5q41OVFICNmUzT1wIHvHfWMPeC7216sEB0QZ/YSng8IJzfkdmtufvPtgNfc
FofLUAjDhWxTeD3go+T9nj96TXW6ToU7HcjS56dSHlZc15sr2AMmP3UiQfA+dwg0
BdlKmRtBQFXA1Fvaook5
=vYSI
-----END PGP SIGNATURE-----

--=-2z0ZshhSuwjoZybveNnG--
