From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 07/17] ixgbe: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:03:44 -0700
Message-ID: <1396119824.2287.29.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <f62f13a9c37b77ad0141bf759143b8da88d264cf.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2o4QtSovNoC4XDugGaCm"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28584 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbaC2TDp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:03:45 -0400
In-Reply-To: <f62f13a9c37b77ad0141bf759143b8da88d264cf.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2o4QtSovNoC4XDugGaCm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)

Thanks Francois, I have added your patch to my queue.

--=-2o4QtSovNoC4XDugGaCm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNxkQAAoJEOVv75VaS+3OD/cP/RP/xgaXxreiY4P8yRVW8exT
ZHrtKRkYe1lTTZMaHd8Ira4lcVLfzEErFr8sjK44oTE8XMbhMo474X/mmqlXLK4J
DCEqdnjvJV93Afrgb8HNecvl5fbSUL8A40QFf3A+B4wqUXRaAF/U1+0eB9ojTKYu
MumY1F094Nth3pbU1T2oO74n0bkpfl6KMYlvDyUsuNlmfoO9icnKLTqfF9Gl0TXe
YD+xPszyW89o17wqpooXH6hbb6vASlnQbkLZ81hPhkGrlDhwJdiHswR3ARg1Q8pw
v9Bp0uO3sK9ImLy/np6hwQKF3LlkHu/hdDX51d0dU7+4XB/oWY5izJmOMEoklFCs
7z9KegHlP1hkXo49wD48gGPw8ymhrj9GzTd8GR0TIFCqe1N0790RM30msBeWEEie
0H7O3tWdiKrq8ndvctGLTBn+Rj5bca/Q7+7AomBmTDOnP/O+oKWGPwfDgeFZXxkC
pj4csZ66uYqCC4yAVAFl8atOllb63V5yzIjZomRqnV8k1Sbze1sPsH+n9n7CclSG
ah1f6FGcNHwAterw0OLqC4EAxWeUUQV/46UnMz3/MKfr7WN92hMHOqTu1x7d53dU
C37zAfNtCrGOoLGv4Fxsg8o0t19SgMtb2OzHyX0anAqmRp9aDOK9GN4bz25wn3gl
TikH186PO3WjzIpg8coh
=TphK
-----END PGP SIGNATURE-----

--=-2o4QtSovNoC4XDugGaCm--
