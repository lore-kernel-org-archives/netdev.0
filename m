From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] e1000: Use
 is_broadcast_ether_addr/is_multicast_ether_addr helpers
Date: Fri, 16 May 2014 22:59:29 -0700
Message-ID: <1400306369.8175.87.camel@jtkirshe-mobl>
References: <1400227238-13428-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YbRq9eXOFwA2AxxbzRHv"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51694 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756223AbaEQF7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2014 01:59:30 -0400
In-Reply-To: <1400227238-13428-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YbRq9eXOFwA2AxxbzRHv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-05-16 at 10:00 +0200, Tobias Klauser wrote:
> Use the is_broadcast_ether_addr/is_multicast_ether_addr helper
> functions
> from linux/etherdevice.h instead of open coding them.
>=20
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_hw.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Tobias, I have added this to my queue.

--=-YbRq9eXOFwA2AxxbzRHv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTdvrBAAoJEOVv75VaS+3OLq0P/R+/tIdC1Uawd8FE5R+vYQEz
3S4ERkW/Q5ux6JDOzpuvyFJ6K0o4GXQp9Q3enrVINdsKz6YQI1/nrXKHUNN54fJJ
bAzA3EOIRDH7V4JT52SR7h2RmPSYFCbnHbNXTbB9reMS3svTL/EVtQeopjdyZatZ
F+GByR2h0/9t16m0QEexpdoRZGp8mSoOqADjyRgS2UT4Ai+Sgvm54GTrQKZHbvj0
XuKX877mNBr8Of0M4cV38zm+joTPOAe0xs2uu8MjlmguawV+gbtj8h18deZYdZQE
PgIb4hwiJhb5sJgOlOBvk3hfv+vGWI7muFZdASP6GRUwSjfhUOR7HILbXhgczGn8
/2ZdN71P6cFlBNw1LzprGaLGb3qMaCHf+frs+XFZnNKTHFw/UxwZKmUumhg39gmm
NiS0qZBy6eKpReJjo5Xdo647gxNBEQCi7IPOn4aWmuU3+YBbJIIr1i9vLI4dMs1U
4gufcyy7UlCePbgcVXb2cPEktDnMan3dzlyvTclzPu2IHFaeWFXdYDGfzK0KMKYY
g2BExXUUCPDrIMJDWUdrEY0+Z23O/pTypij8aRLpG3APiwpzC6kOdTdVwTDo81Mb
Wm+DCURDOH5xXcK33YSm5kearYdDNWJMTbvaYFsxFFrcMLjS4LiwTGDD5Sp8+MF+
1ysv5DEBaWlyyro7YgKM
=pcek
-----END PGP SIGNATURE-----

--=-YbRq9eXOFwA2AxxbzRHv--
