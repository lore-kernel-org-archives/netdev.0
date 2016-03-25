From: William Dauchy <william@gandi.net>
Subject: Re: dynamically set number of queues for 82598 devices in -stable
Date: Fri, 25 Mar 2016 16:22:56 +0100
Message-ID: <20160325152256.GA20821@gandi.net>
References: <20151127100557.GB21147@gandi.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HlL+5n6rz5pIUxbD"
Cc: William Dauchy <william@gandi.net>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:50491 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752026AbcCYPaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2016 11:30:18 -0400
Content-Disposition: inline
In-Reply-To: <20151127100557.GB21147@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

Any chance to get an opinion on that?

Thanks,

On Nov27 11:05, William Dauchy wrote:
> Hello Jeff,
>=20
> I faced the problem described in commit 7e3f5c8:
> ixgbe: fix bounds checking in ixgbe_setup_tc for 82598
>=20
> This patch resolves an issue where users were not able to dynamically
> set number of queues for 82598 via ethtool -L
>=20
>=20
> I backported it for my v4.1.x build but I was wondering if this could be
> a candidate for a backport in stable tree at least for v4.1.x.

--=20
William

--HlL+5n6rz5pIUxbD
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlb1V9AACgkQ1I6eqOUidQF6WwCfbjaq8WjA34WyjZYIZkWaygXU
TAgAoKKCAiLNzJcTC+/4z850dmkOTxoc
=T6Dc
-----END PGP SIGNATURE-----

--HlL+5n6rz5pIUxbD--
