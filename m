From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: fix error return code in i40e_probe()
Date: Mon, 23 Sep 2013 14:09:28 -0700
Message-ID: <1379970568.1906.0.camel@jtkirshe-mobl.jf.intel.com>
References: <CAPgLHd8qwuJ4ry-DVExF7mv83FBqYts_7wMO8xikdeL+3e+yUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KC98DuBn9s8DQ6+IGftQ"
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, shannon.nelson@intel.com,
	yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65487 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752406Ab3IWVJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 17:09:40 -0400
In-Reply-To: <CAPgLHd8qwuJ4ry-DVExF7mv83FBqYts_7wMO8xikdeL+3e+yUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KC98DuBn9s8DQ6+IGftQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-09-23 at 10:47 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> Fix to return -ENOMEM in the memory alloc error handling
> case instead of 0, as done elsewhere in this function.
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Thanks! I have added the patch to my queue.

--=-KC98DuBn9s8DQ6+IGftQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSQK4IAAoJEOVv75VaS+3Ola4QAKE5bmD9gmxRowaL3T47O3S9
oI4Av2LxZt5Gk5jRgFz/Pu+ZsvSH6f+h0DrmvAbIAjkHGoN4c3ub2DEnVRAvKxQJ
yIRlSBkxNC3lkkvyL9EQuem8sW7BRyXIO9XAm/X5x+Qe+ruiuh8XyJ1ML2V3IS0i
yiE4CoXhSIyMyYnymx/sPTOAjH+hi/OMQg3IuksgokC254B0rkgxVysj8VkfuGUe
rroZH/fojk1cfJg2t83lHM1BgoXSz/9FsU+yJZZ1/QrOXvdl51CgcSC9DZdsPwv5
wpuHtcEnCtX1/AAND+LfR62CzQF3IZzfU3RxLqPoZW709WcOrTu1Jgant65D+Goz
LJ65ypKsKl/uWttjnIrm+YkFmOsQgUfmxQAeAhw3ZSeIn7ZB1fm7aVJUeAtcQvWp
yFzSbquvCYlV+IRFgzHfhmtnTHtZG2csD1OJ2W3w4JNOCt4Bmz1vJ9Ef3LKZiCko
CBYE64nxCQpxcKTZSCwAjCwiq2HGbFQvk0DwOFD+NBfbEe/smzCxIUxMZdX8zK0H
WxZsOMl/jsB8qkRcYHaJ+/+potv6cMXQtPdMvAgOAOjjO6Kbh+x+TRPMNAYNMk4Z
Cz9pYGJiJYnZKeZ+5m21sBhgdJSKvr9rlee7TJA3okFawhISuWXCO91JdMSTzYAv
uw6RMhGpxXyf5ynjzeMh
=qBfw
-----END PGP SIGNATURE-----

--=-KC98DuBn9s8DQ6+IGftQ--
