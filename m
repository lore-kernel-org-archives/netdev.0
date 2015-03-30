From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v3 2/2] ixgbe: Add the appropriate ethtool ops
 to query RSS indirection table and key
Date: Mon, 30 Mar 2015 16:37:32 -0700
Message-ID: <1427758652.2497.101.camel@jtkirshe-mobl>
References: <1427739538-1038-1-git-send-email-vladz@cloudius-systems.com>
	 <1427739538-1038-3-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0nferfY9MEz/08w09Q8q"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:35077 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753633AbbC3Xhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 19:37:33 -0400
In-Reply-To: <1427739538-1038-3-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0nferfY9MEz/08w09Q8q
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 21:18 +0300, Vlad Zolotarov wrote:
> Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops
> callbacks
> implementations.
>=20
> This enables the ethtool's "-x" and "--show-rxfh[-indir]" options.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 42
> ++++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  2 +-
>  3 files changed, 44 insertions(+), 1 deletion(-)

Thanks Vlad, I have added your patch to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-0nferfY9MEz/08w09Q8q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGd48AAoJEOVv75VaS+3O8BgP/0OS2kEDVIDTMIT2rOvSJz/e
ZQl7JeYMN+OUCFSQlRuZAf/4vws9I36AKH55owI90DVF0b1Ng6xVYXkgeSw6Qrpn
cEAEL8pL2yXarx9U6D+xcAxUmocAaj0a0IlWLTKxMe1tFtRQev8wqnWneW0f0eY2
dlM1HX6FnVCuBtOAth03+hZHlAT1vNOW+Hed6bgWs8fGzEcmamSimG31ecHlw/KY
Q7at/M/1wuf6rEeNvS4Bc3kJSh67TW4ZUbp4vd+VAcr9mh6cRlVZ83h2D3XMGE+m
/h6yJfrj6TD8bLRNPsmPo0Am0AVr4NIdnMmP7e06Uj4eNAz57P0MU7X07PTiXk9j
MKX3xazc2SmmSTcSphVRo+zkxCV43qgMQe2tnKtYF/8Z4kpFMCZU4Mn15aFGUdvk
om4cWJTfm+ZASM2jKZlDk5ghg+TuXzhaLsdGWsL6mw68nztGN3Dj3D5W0Szk2j6i
njKWrsbGKA8KY1JpGwuWct2i76u0aHj84DP4naHxK47nye5668RAQIdOfWcz45v+
tY9D8XwXYBBwVdn9V6XIFV5UvpV5uXOTnY7Fjln1PxTQ3VDkJDOdv/TW/MsC67y0
ruB02MKoy5FOBZXb2F/ZSJdhSMmbB35RNVvULXLhUvJ9IxXvxXoeg7j7W5S4z+kL
jC6DNHJAODbwXK9CARVR
=SVkT
-----END PGP SIGNATURE-----

--=-0nferfY9MEz/08w09Q8q--
