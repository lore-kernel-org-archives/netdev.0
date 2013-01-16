From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] e1000e: display a warning message when SmartSpeed
 works
Date: Tue, 15 Jan 2013 18:54:52 -0800
Message-ID: <1358304892.2177.16.camel@jtkirshe-mobl>
References: <50F60F18.2030108@jp.fujitsu.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-prqP1xv9ET9xhKgKXg//"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, e1000-devel@lists.sourceforge.net
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54960 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754976Ab3APCy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2013 21:54:58 -0500
In-Reply-To: <50F60F18.2030108@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-prqP1xv9ET9xhKgKXg//
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-01-16 at 11:23 +0900, Koki Sanagi wrote:
> Current e1000e driver doesn't tell nothing when Link Speed is
> downgraded due to
> SmartSpeed.  As a result, users suspect that there is something wrong
> with
> NIC.  If the cause of it is SmartSpeed, there is no means to replace
> NIC. This
> patch make e1000e notify users that SmartSpeed worked.
>=20
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)=20

Thanks, I have added this patch as well to my queue.

--=-prqP1xv9ET9xhKgKXg//
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQ9hZ8AAoJEOVv75VaS+3OFVUP/i8VaD519/38ygEIRW/2LPGh
ZuYIhCyyxFCtwihL76+QOWKzWU5IuyyastHPoKSA4+opgmVRS4RbO+7aqqzz/2rs
QOpbfoOqCwn7leABt64Wk1rgEroz8PWKEPL1TJQzTfoB2rnP9qk9IYzVBm3gBOgB
/LjVdvIUoQXefVkqd3bU0lgYhLHMv2YipxMP2xGbDhnFS9OvpaUbOl4UbIc0M+lz
yMfPdk6JaRieo3xpi3ga+0VCut8A3OhRIjM/bgWlhUCrjtvM17railMFxC0jg7/r
TptISHmg46MLsmBBlvi9UM2pUJ+sn2ClklHKn2UM2zt0XONbK+X06rzSI9xu93F4
XwIkmfxjRHypktriXK5Lzaf1Iy4H1vDmulAy+4WTM+7HyXZWPQoK058xjfgC0+y5
hYNSJ6AwRJsVG4NKKiy5KJzzb/Z6b8ZvHx0WisG1Kwrw1Je0teqPvnvrXrENkySY
ZD60yfYhihiWvYJpzI4wSDGGwwsjaRbsZgNncq9H9KBzzlGWqv5O3hHwmfe4RmRP
56l+ewtWBsGV6EkVigpNW0TWRyb5g4pLTl5g8TNpDhRhiTjNKpRDyii+z2FgH+/k
v9kHZcjG2P3gWbJ/xYvSeO5SwT3JG1cRaog1c7xfesQL4PoXz6N76FBwxP8Pz/lx
zrmae5jrxl7jvPdER1Jz
=BJ0g
-----END PGP SIGNATURE-----

--=-prqP1xv9ET9xhKgKXg//--
