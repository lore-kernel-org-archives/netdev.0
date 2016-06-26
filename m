From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool 0/3][pull request] Intel Wired LAN Driver Updates
 2016-05-03
Date: Sun, 26 Jun 2016 11:04:51 +0200
Message-ID: <1466931891.2504.31.camel@decadent.org.uk>
References: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-M+aMaOe2HyFnJ/trtpsl"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55180 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751675AbcFZJFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 05:05:02 -0400
In-Reply-To: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-M+aMaOe2HyFnJ/trtpsl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-05-04 at 09:44 -0700, Jeff Kirsher wrote:
> This series contains updates to ixgbe in ethtool.
>=20
> Preethi adds missing device IDs and mac_type definitions, also updated
> the display registers for x550, x550em_x/a.=C2=A0=C2=A0Cleaned up the for=
mat string
> storage by taking advantage of "for" loops.

I've pulled these.  Thanks for your patience.

Ben.

> The following are changes since commit deb1c6613ec14fd828d321e38c7bea45fe=
559bd5:
> =C2=A0 Release version 4.5.
> and are available in the git repository at:
> =C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/ethtool mas=
ter
>=20
> Preethi Banala (3):
> =C2=A0 ethtool/ixgbe: Add device ID and mac_type definitions
> =C2=A0 ethtool/ixgbe: Correct offsets and support x550, x550em_x, x550em_=
a
> =C2=A0 ethtool/ixgbe: Reduce format string storage
>=20
> =C2=A0ixgbe.c | 173 +++++++++++++++++++++++++++++++++++------------------=
-----------
> =C2=A01 file changed, 95 insertions(+), 78 deletions(-)
>=20
--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-M+aMaOe2HyFnJ/trtpsl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXb5qzAAoJEOe/yOyVhhEJzQ0P/iOXK0gDp6KEW6HKQBzvq3vq
AjLlSo2n3ex02rhbHCNt6zQzUMl78u693vccA083jiBtDgN5M2mmAOWhSjJdqUbO
u+s5gPb5OfNVJe26hRPRUYt88qWdDT59nOKMQgc6b4Ck3YbnvbYjtWsReZcAcoyP
IvlRAfWsnEkp8AbqiGOHDSBdyyCaZrmfLNXtw5Lin9zRav6DcXNKcYVElREtYFTF
/DWSHs8iLI/7daeB8mJCDlQhDVHHSX7oEF/C3qG/7/BZILmw6H0Ilxa+smg7Goeo
e4OyhkgXOGZVeDaA3vMby93zEl27QwVpdyAfvDo/qhXeMs3wzVxhR9FAdTOuOpiz
AscPTR4b31qf8h6WEJOvUeqdgRcd/MeuTVc3HYxNFKd/RiWuyFbMYCaadsj8Zk0v
oA7m/43YxGNWE/VWzWtfFt0YvrsWA+2GQDszvflSr9MbgWXYMUGZIl9eED7ZJgbj
HNTZV/tobpZB0TE46OHBlG0SGalNM+PbdQRfW++5NMymA+2pf/lgjpCWveT12sqY
4H+Ey/5u6wlldgSv+fq9Kuz8Lr4CXLk5zfSJ2jydS2YraXkOjopz0YOr5q9NEG25
8D2GmaEbVgRjrTJQg0IcbTLViI5BZ9mCnwMYOifUHXYZdU89PJhb/vv0lQZf7T0h
rAVhK0DmnjUDOCT3Crey
=oAVv
-----END PGP SIGNATURE-----

--=-M+aMaOe2HyFnJ/trtpsl--
