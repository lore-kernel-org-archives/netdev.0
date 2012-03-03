From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Fri, 02 Mar 2012 18:27:52 -0800
Message-ID: <1330741672.2707.100.camel@jtkirshe-mobl>
References: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/dE1DzQAbx97y2HW1m+h"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:45206 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806Ab2CCC1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:27:54 -0500
In-Reply-To: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/dE1DzQAbx97y2HW1m+h
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-03-02 at 18:24 -0800, Jeff Kirsher wrote:
> This series of patches contains fixes e100 and DCB (ixgbe, bnx2x).
>=20
> The following are changes since commit b4017c5368f992fb8fb3a2545a0977082c=
6664e4:
>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
>=20
> Ben Greear (2):
>   e100: Fix rx-over-length statistics.
>   e100: Show short v/s long rx length errors in ethtool stats.
>=20
> John Fastabend (2):
>   ixgbe: dcb: check setup_tc return codes
>   net: dcb: getnumtcs()/setnumtcs() should return an int
>=20
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |    4 +-
>  drivers/net/ethernet/intel/e100.c               |    8 +++++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   30 +++++++++++++++--=
-----
>  include/net/dcbnl.h                             |    4 +-
>  4 files changed, 31 insertions(+), 15 deletions(-)
>=20

Please disregard this first pull request, patches from a previous pull
request were sent accidentally.

--=-/dE1DzQAbx97y2HW1m+h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPUYGoAAoJEOVv75VaS+3OSagQAKSCx2Gihrebr/67up3Jak1o
ZhLhP+2PVTceYMeGogsyvr/MzKG2mJQ+nV5ON4oAEnzmLHebF7Co7CDjWSRRYZf6
n5ChXezNBNaA6eaVVxdzgezfKaBUvlSlLPo8PJ7wrfmT7PntX2zlx/wnCjQ0cmKo
CJxW6macH75BEtZpXZQ7uLrGYLbYvkLUTVp4eNqBAcbiLc4DelTWbC0Mo5QnqoUK
R9WHQe/FhXo0EobdAcSu+eWlR9Jo+C13bkltpRBBC9/gbZn5mbnqJYhoa3Xmft2w
sk8CIIVKNIjc2fLrzp2r6Dldfn75o9Xfi9ETrR+nMlaYGjKDs630J8OGN/kccbU8
eK8hONKWUJCvPkWFM+r8WNFoujR8fG/S0Rh5LoVfLYCcvT9/RDOkowyC3lYPKgFW
7oFOundqxtUJ02nxLHFx8cRntuWY8OoX15NRcunUAO2ZRvJHtLMvPcWtHL+jlwor
Xyv7QFD+W2jdeFHbAyeVZsmNIsrPxw4i5F1Ea+iJa02h2NLEEyF6b25u+6PzwkkM
7g5ZdRdjzROAX1NcCc+ZOMnJMPLLDw6Rj+x6UzuDe0hzzRzfDZUBiQEW67rWRyog
AQhpvjnTY/rs5ApyFXoNHC9Na1NUW5NR38YNxv31iMNsi+JIk1JCTzEGF+dvMe7o
wBK/p5nmUJ99BqtXGO1w
=2HGA
-----END PGP SIGNATURE-----

--=-/dE1DzQAbx97y2HW1m+h--
