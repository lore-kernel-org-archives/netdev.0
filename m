From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool 0/3][pull request] Intel Wired LAN Driver Updates
 2016-05-03
Date: Mon, 16 May 2016 16:46:05 -0700
Message-ID: <1463442365.2609.39.camel@intel.com>
References: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pzrV0/fS8HLhp9KrWZG0"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31627 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbcEPXqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 19:46:42 -0400
In-Reply-To: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pzrV0/fS8HLhp9KrWZG0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-05-04 at 09:44 -0700, Jeff Kirsher wrote:
> This series contains updates to ixgbe in ethtool.
>=20
> Preethi adds missing device IDs and mac_type definitions, also updated
> the display registers for x550, x550em_x/a.=C2=A0=C2=A0Cleaned up the for=
mat string
> storage by taking advantage of "for" loops.
>=20
> The following are changes since commit
> deb1c6613ec14fd828d321e38c7bea45fe559bd5:
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
-----
> ------
> =C2=A01 file changed, 95 insertions(+), 78 deletions(-)
>=20

Ping? =C2=A0Ben do you have these changes queued up for ethtool?
--=-pzrV0/fS8HLhp9KrWZG0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXOlu9AAoJEOVv75VaS+3OXv8P/2BWDieE0O6ZSPxCQAYGtDml
P48xkrrilbYgACuvrRXJOL+wpjpK4s7VdBYLO/c+JE5AIxYFY/UTiHSCOiJMLqKs
wpVWZsPYKLCEGJGc1878QpCyDyB5MV/ajQ097vel/4J0Gmjk5yl1tVtq2H18gHcw
KETk5ZFZ5i45G9CpBufAsRBm4wmScmT+XyyK2TIXgyOPiy/R2UkONRcAGq2q/6hv
q0MCS0Q9m5jM+E7QIP8PGZnGrBEOzj7/qCpN9nAqCT/qrxsLjwA9P6BDt0vmujQM
ut8DDppkdHHoUyarzit2uC9i12RjDg1H7kW57kv6v0a1HgyNjWPJfQUizozqIU04
tA6I25zg34fHuEAKV8+MFjEy8IQUFMFYrXm7o3sAR0nPq98Cg2GPOhXYh0mh1BLu
+zbc3s9SRH/81Gf+2wrXJ9FnP7gLfhfShYOwn1mWBRfg6OJH9p/gCcmmA2nJVj4k
V8SdPR2aHwXEXq9qxaYDv3SAF4FsV8B8t/kw26RBdqEz8Zp3X1t0Gn/c2xLHkf4M
dA0w0HFfdK/7lhWpCYhiOs5HicRkfSEfEohJo9kJgNhU9i4ufy3v7xrvPMX/reCK
uF2W+E9TX4ee5CD/gr3OArBxgsg3e+VMPUN/DWB/Jo3w7dUZojz/b6ZOqFakW753
ofpkm6NqV3/JF3N0b1bK
=dphl
-----END PGP SIGNATURE-----

--=-pzrV0/fS8HLhp9KrWZG0--
