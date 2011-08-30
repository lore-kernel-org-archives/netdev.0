From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 10/14] intel: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 03:52:42 -0700
Message-ID: <1314701563.2204.30.camel@jtkirshe-mobl>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
	 <1314695910-22344-10-git-send-email-ian.campbell@citrix.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-r7kGmM1Nfw1vJAKjt6Yc"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28404 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898Ab1H3Kwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 06:52:44 -0400
In-Reply-To: <1314695910-22344-10-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-r7kGmM1Nfw1vJAKjt6Yc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-08-30 at 02:18 -0700, Ian Campbell wrote:
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: e1000-devel@lists.sourceforge.net
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c     |   16
> +++++++++-------
>  drivers/net/ethernet/intel/e1000e/netdev.c        |    7 +++----
>  drivers/net/ethernet/intel/igb/igb_main.c         |    5 +----
>  drivers/net/ethernet/intel/igbvf/netdev.c         |    5 +----
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    6 +++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    3 +--
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   10 ++++------
>  7 files changed, 22 insertions(+), 30 deletions(-)=20

The changes look fine to me.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-r7kGmM1Nfw1vJAKjt6Yc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOXMD6AAoJECTsCADr/EWU0msH/3mZssdAy46HGK3SM9y3blDq
jbp2aHsSzqqXe2arNPwhGF49DJDmH0yjTIwE4DQquynlwnCoZ5ECrmxzyejYNz40
vpDNKjvX2YBX++wf4W7AhtqHHlatiwbIYSSjuBBG8tjmomzPX3enqiwtv/12emro
sRuyKYLyZzqVuSPk7A4sEZHS5Ki9fwau/THDf5n2oWRuQ60IjK9aevGf87oFKs+U
ki7rZJ2bGXcnsnlsOaoGiWTwWkCVFTjZLmePzkxzamWXTDJqNLkFSEFg5k+bthyZ
2lCD/i3q9ZAJyshnvyU/68bINhLKRjOz7RH1tZEtc5ArePbe71qg3WqFwHjgLhk=
=2nup
-----END PGP SIGNATURE-----

--=-r7kGmM1Nfw1vJAKjt6Yc--
