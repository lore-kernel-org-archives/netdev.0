From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [resend PATCH] ixgb: use PCI_VENDOR_ID_*
Date: Wed, 03 Aug 2011 17:09:40 -0700
Message-ID: <1312416581.2294.165.camel@jtkirshe-mobl>
References: <1312389773-9761-1-git-send-email-jdmason@kudzu.us>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-i0f+JAplIxQ+TTnTFNN+"
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:10266 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756083Ab1HDAJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 20:09:42 -0400
In-Reply-To: <1312389773-9761-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i0f+JAplIxQ+TTnTFNN+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-08-03 at 09:42 -0700, Jon Mason wrote:
> Use PCI_VENDOR_ID_* from pci_ids.h instead of creating #define
> locally.
>=20
> Signed-off-by: Jon Mason <jdmason@kudzu.us>
> ---
>  drivers/net/ixgb/ixgb_hw.c   |    5 +++--
>  drivers/net/ixgb/ixgb_ids.h  |    5 -----
>  drivers/net/ixgb/ixgb_main.c |   10 +++++-----
>  3 files changed, 8 insertions(+), 12 deletions(-)=20

Thanks Jon, I will add the patch to my queue.

--=-i0f+JAplIxQ+TTnTFNN+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOOeNEAAoJECTsCADr/EWUFeoH/21nEqB0guREchsOa9qPV+Bg
LRguWeYaM7DWkcVsQn0RuJ0zodcRqL3SDZv+p8WHpLsioGesAxqd2smk+NC+yfuJ
6AhHLNg+LOUL+OO5R47jXvbkUr0LkTfreAWaOxNRqqebmnPwpc3B+ooJHpA3RYCm
lVu7c5ppAxpQngVsj6WKSsi/oQ5YzKW4fYy9pfDqjyGN8t44kHLr4ohaImNUMH/L
glzxzBXQGE9xKOz9E75S0dihhsjcMAV41u4Z7+g0iXTSxI+OXlq+QQAGveYWsaLv
jf+iA+dv4Bcu31rbwNc/Wv/ZuM0t9wuhytw8C42FSxn+1yz1JRRQjH2jVACAydA=
=HeJa
-----END PGP SIGNATURE-----

--=-i0f+JAplIxQ+TTnTFNN+--

