From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] ixgbe: Support sending custom Ethernet FCS.
Date: Mon, 05 Mar 2012 17:34:00 -0800
Message-ID: <1330997640.2817.0.camel@jtkirshe-mobl>
References: <1330996704-13076-1-git-send-email-greearb@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2VYkr72haFlMgOGVa4B+"
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34883 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758066Ab2CFBeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 20:34:12 -0500
In-Reply-To: <1330996704-13076-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2VYkr72haFlMgOGVa4B+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-03-05 at 17:18 -0800, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>=20
> Including bad FCS, used generate frames with bad FCS
> to test other system's handling of RX of bad packets.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 23a4665... b6e51f9...
> M  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)=20

Thanks Ben, I have added this series to my queue!

--=-2VYkr72haFlMgOGVa4B+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPVWmIAAoJEOVv75VaS+3ObG4QAIVx69dvzJazh5f0iA9lpFmn
Q35i3VkP7rq83Xwa7vIHyo8zPoeCUJ9dsbThgpB4ZIllL0uhpcegj9/PnOVvG0pQ
PKMV2tHgVHEFnpEclHLa7QFFsE5J/wDGY7/UaVWOFJL3sbRtw5RtxFS0QWVeTU8D
xrwSJbWq4QG5X/ItWHZ+wdhLwqnKd2ARkXqhJ8V3mbl8EFQDUyJEwjC1HgUnKtyK
hTYmXDQO6QRGLFfKfxrlfijTJOUfcoOSHpmywPntRn5QU6hU5PeqvHYoMTHkte5N
NKdBOktKVDsC46qZf93DIpB76cNlg8+IfrMcgqZMwATB+MpDKkUI1E4my7RxPFpa
/m8mc3aChs2zZ8BRDT5OcgWydJWtUjYiymKPJpVYn2Cw+fT3Ke0AnlMhl3BInSdT
bf7OoVmK2pAenlN8pJGkc6BgSQCyQbL9orw59gUKH46ANWqjYwk2PQG+1px0Cu/q
X0ArOpMrrIqUT033/xgiqvp4xSHr8o/QRfZXqYZ2v2xY15nhBdc6NHbpiEMyQ/Zp
Wlt0V5sr4wOuwgMZKzmn/BuZqR5QFXEm0e9UW3UL60tZVwp2BXntyeCLIljhfYD/
jk84juE/aJkQ+k3lM3/d3vtDo8ElmnssUIrejq2L3oCdP1CjXVbHOSW9gCDYhMUf
ulfo/NLh/4bG9iUBtuTq
=1TVc
-----END PGP SIGNATURE-----

--=-2VYkr72haFlMgOGVa4B+--
