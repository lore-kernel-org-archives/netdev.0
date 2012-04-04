From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH V4 net-next 00/26] ethtool: support time stamping and
 phc clocks
Date: Wed, 04 Apr 2012 03:02:28 -0700
Message-ID: <1333533748.3046.28.camel@jtkirshe-mobl>
References: <cover.1333529504.git.richardcochran@gmail.com>
	 <20120404.052916.1495763141439052807.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vwcS7Iqh5l3W5VfrJwHX"
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, mporter@solarflare.com,
	jacob.e.keller@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13897 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756021Ab2DDKCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 06:02:30 -0400
In-Reply-To: <20120404.052916.1495763141439052807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vwcS7Iqh5l3W5VfrJwHX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-04-04 at 05:29 -0400, David Miller wrote:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Wed,  4 Apr 2012 10:59:15 +0200
>=20
> > * Changes in V4:
> >   - drop two patches requiring out of tree support
> >   - added Ben's Reviewed-by tag on two commit messages
> > * Changes in V3:
> >   - works without ethtool_ops
> >   - does not require special privileges
> >   - neaten user space tool output
>=20
> Applied, let's see if this one compiles :-)

Just to make it clear, I have added the two patches that were dropped in
v4 of this series (igb & e100) to my queue and plan to push them
upstream through my tree after validation takes a look at them. :-)

--=-vwcS7Iqh5l3W5VfrJwHX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPfBw0AAoJEOVv75VaS+3O+FsP/ixpCP9jgxm1YgoKmvfcvYa9
bIuy7OUrr0SRtlngqNfATu5CXDWeg05OI5r/Dl3C06djRKt7O6JlkKSnypxmZy1U
rAuyfL0qq2RJTEXT1CwFWEQ/QzN9hNc2XyN1Xk+3k25DO6y/4VqzWlvPw/YnfiMw
YwVz6OEPAU19pMoVM7VG32+BUPWUqSapYvut1FMS3MSMg57lW4LA2ASo7S9V/BWm
s3o9dLs9ShKAK+KkrOjfjAu3xeddfz1fGvaqDKkuh+l3zFZJgrKiXqyCyzx2BK81
xZ16mhp0MUmm4N5H9fjPr0xcVq2NrWGTBK1ojpJhDDhLwzx0kwJaXuCaeifvuX7C
sAC0fkCSQCPoRYkKZItkfGH2+OrlBMpYRbMCj8Gf99MK4zRSF7yh3mjR0x64gBka
VBpT6xouzglOGVDTGazh2gqIFupQb44J6cjjJ8AoyGOErgP+rQg91QSwrzrDz7ah
+LUqN+s8Z/LQmMrmihAtl9qPfGwk7er0CUZShU5KwGQ9c4rwqEosuZKFbeQcLstt
yYuSte21dXBxisyuFReRmbFbm2vgU3Np0XXKNnlQgww4c7KFj4z5fXAKEUmudLRD
OI1y1aP8fEFRvyFzIt/97+4YQfl9h+JKzZ6oidVZma/VpUSmFqv2ZJ9KhM9pXKOV
vYi5fp9vyJxHVi70XTdC
=cYfg
-----END PGP SIGNATURE-----

--=-vwcS7Iqh5l3W5VfrJwHX--
