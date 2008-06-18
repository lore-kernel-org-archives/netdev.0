From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 1/2][Rev4] fs_enet: change fec_t to struct fec
Date: Thu, 19 Jun 2008 09:49:59 +1000
Message-ID: <20080619094959.a73f6501.sfr@canb.auug.org.au>
References: <1213802154-28968-1-git-send-email-jrigby@freescale.com>
	<1213802154-28968-2-git-send-email-jrigby@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__19_Jun_2008_09_49_59_+1000_dj5i/pplpzFgJzWn"
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, Sam Ravnborg <sam@ravnborg.org>,
	netdev@vger.kernel.org
To: John Rigby <jrigby@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:41045 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513AbYFRXuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 19:50:15 -0400
In-Reply-To: <1213802154-28968-2-git-send-email-jrigby@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__19_Jun_2008_09_49_59_+1000_dj5i/pplpzFgJzWn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 18 Jun 2008 09:15:53 -0600 John Rigby <jrigby@freescale.com> wrote:
>
> This is in preparation of adding support for
> MPC5121 FEC.  The 5121 patch needs to add a different
> struct fec because it has a different register layout.
>=20
> This patch allows the 5121 patch to not include a typedef
> fec_t which checkpatch complains about.
>=20
> Signed-off-by: John Rigby <jrigby@freescale.com>
For what its worth:
Acked-by: Stephen Rothwell <sfr@canb.auug.org.au>

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__19_Jun_2008_09_49_59_+1000_dj5i/pplpzFgJzWn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkhZnycACgkQTgG2atn1QN9PpgCfVCUszWgZ/ReffAH9Kg5mDWHA
bzcAnRk1Y3OwU9lyk71/Bwx9pq3We5eJ
=98MT
-----END PGP SIGNATURE-----

--Signature=_Thu__19_Jun_2008_09_49_59_+1000_dj5i/pplpzFgJzWn--
