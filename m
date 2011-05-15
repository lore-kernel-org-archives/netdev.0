From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 00/13][pull request] Intel Wired LAN Driver
 Update
Date: Sun, 15 May 2011 01:41:30 -0700
Message-ID: <1305448890.3355.3.camel@jtkirshe-MOBL1>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110515.012108.15947576632987708.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-RmTkC97tmEjIyggNLXbe"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27765 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755778Ab1EOIl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2011 04:41:29 -0400
In-Reply-To: <20110515.012108.15947576632987708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RmTkC97tmEjIyggNLXbe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-05-14 at 22:21 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat, 14 May 2011 18:23:34 -0700
>=20
> > The following series contains updates to e1000e, ixgbevf and ixgbe.
> >=20
> > -e1000e: minor comment fix
> > -ixgbevf: add support for macvlan
> > -ixgbe: mostly cleanup with the addition of support for a new adapter
> >=20
> > The following are changes since commit 7be799a70ba3dd90a59e8d2c72bbe060=
20005b3f:
> >   ipv4: Remove rt->rt_dst reference from ip_forward_options()
> > and are available in the git repository at:
> >   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 mas=
ter
>=20
> Pulled, thanks Jeff.
>=20
> How are the ethtool op conversions coming so I can apply the patch from
> Marius that deletes the deprecated ones?
>=20
> Thanks.

We ran into issues with the driver changes, and we are working on a
revised patch(s).  I will end up breaking up the patch into several
patches because we have the work done for some of the drivers, and are
still working on the remaining changes.

I will make sure we get the remaining work done this upcoming week.

--=-RmTkC97tmEjIyggNLXbe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNz5GxAAoJECTsCADr/EWUFRQH/1rBOxXsNiAlOUE5Uvo3Tfxl
DuO4RzDRtqwUHCG/OHG6ylTHjjNd4NEOHBP3LpN/lD8x6OAQpogesnkTaMzXWuvS
GaWrEvgkOR5zxdH1EdZMhyaZ9vAGDAaQwMRGvsw8PqeiQcue6QjXrqNns0fp+Rje
Sr0SaOO/Qm95Ltr2puW2BA1/XFO/9u6vJIxoEzZmKUP5vx/3r/WU4DNsjqvZfCVo
mhibupeAQPigUKqrt7qDLdwRcz+THmtoY7KJfD6Y+7VqZO4FFyIxvWa06SJhg/nZ
6tYUy5dbHLaLI63/wQI19Kj/Wx1wc1OJPcdwI/gkFJS6UVqQICdJnGo+rt/aQYg=
=uinL
-----END PGP SIGNATURE-----

--=-RmTkC97tmEjIyggNLXbe--

