From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: don't break user visible strings over multiple
 lines in igb_ethtool.c
Date: Tue, 31 Jul 2012 14:30:21 -0700
Message-ID: <1343770221.2230.30.camel@jtkirshe-mobl>
References: <alpine.LNX.2.00.1207252115321.11754@swampdragon.chaosbits.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vbswknYt06yyL5YW2Pth"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Jeff Pieper <jeffrey.e.pieper@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44105 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631Ab2GaVaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 17:30:23 -0400
In-Reply-To: <alpine.LNX.2.00.1207252115321.11754@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vbswknYt06yyL5YW2Pth
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-07-25 at 21:19 +0200, Jesper Juhl wrote:
> Even when they go beyond 80 characters, user visible strings should be
> on one line to make them easy to grep for.
>=20
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  drivers/net/ethernet/intel/igb/igb_ethtool.c | 23
> +++++++++++------------
>  1 file changed, 11 insertions(+), 12 deletions(-)=20

Applied to my queue of patches, thanks Jesper.

--=-vbswknYt06yyL5YW2Pth
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQGE5tAAoJEOVv75VaS+3OXZkP/An0eflsVIQnNk67j56SVG9R
4A6nBjwAwcIYQqUMJYYiHZcUiQtQDqyrKUwuu/T3sSMT9OPO8fBdChiJiKhQbWTu
g36yvm3kkIEAMD4orxdz3gwomdh1PfOpbLBqB8k0AsihzdpjazD7r364Fl3Wd8R/
+7rg64W/neAHumcv9v3f7lH0pQYfPzGyob2PF3zbzZt2wTM9BvH5iN8Mb1pJjAKK
U867lvq5rrLlF+baaOH0q1ft90qPRMxWeyZCSl4Z4r28vWG7WnNzwhG3ZFC9vKwG
GQo1yLn3WnoaP1Vjj0BonTrAUl8CxhQ0Jp2Y1CZNsJS1qAGYo+TZFkjn1Nv0pERI
mq/G7yfRL25nJhDTagWO1jPKamgBfuMNIuolh5GkfxqE5zznCqaup6+qnFQHO3mP
V25EKnlimcwMmgvrILayxeJK5xvUZT54+eJmPCKHyGcPIU8MNkizsOXnwGzqZ2qo
DwOuqRieN7IR9kt+WJ8+9uxZAzYYdmO3anQBb9Lo/dQOlvRXuQ22R2+PkhdIf53m
UMMjwyGckUQhvvURXDq8mL+i3Rvty7bYdpD4SxJ6qD/lXDUEZbuBDZZ9svXzjuCr
G3l8IygDCNHKFo3liQU1UYerZY29OLuH2eo8N5/C2LjeFIkFFe1/O4TbSA8p298/
JK++R839GTkxms/294N0
=1PcR
-----END PGP SIGNATURE-----

--=-vbswknYt06yyL5YW2Pth--
