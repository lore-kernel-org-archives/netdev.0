From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/10] drivers/net/ organize Ethernet drivers
Date: Wed, 10 Aug 2011 22:24:14 -0700
Message-ID: <1313040255.3940.9.camel@jtkirshe-mobl>
References: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110810.220822.781839847644610294.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-XzlIarNTvWIS6Hg8i4WP"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@tredhat.com" <gospo@tredhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9741 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752179Ab1HKFYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 01:24:15 -0400
In-Reply-To: <20110810.220822.781839847644610294.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XzlIarNTvWIS6Hg8i4WP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-08-10 at 22:08 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 10 Aug 2011 20:27:48 -0700
>=20
> > This is the first of seven 10 patch series to move the Ethernet
> > drivers into drivers/net/ethernet/
> >=20
> > The following are changes since commit 19fd61785a580c60cba900c5171bfadb=
57dd5056:
> >   Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/=
davem/net
> > and are available in the git repository at:
> >   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize ma=
ster
>=20
> Pulled, thanks Jeff.
>=20
> I'll push this back out to net-next after some build validation.

As an FYI, I have had Aaron Brown test the Kconfig and compile options
on this series (as well as the remaining 60+ patches) over the last
several days while I was out and so far there have been no issues.

The more eyes the better though, thanks.  I will start to prepare the
second 10 patch series.

--=-XzlIarNTvWIS6Hg8i4WP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOQ2d+AAoJECTsCADr/EWU6u4H/29IMiWRhGzJDAlXTvYYO/hs
GtFq2VwxtG3FW9164CPa1IroatJ0R+FTokC+3uhaOGq5tnwA9czl6+IJ+P2GBZKH
fwSXl2O1FtF19a1zCqXTG0ybnGcG730su6BqvXhcXfRu+K6eYHFQMuPHJiZMKVch
J3i7mHv2rK8466YNYyZFPFfxOT5Vg6PeHAggxx1Jzb4HYtyHDG2sepL8BTK0ei/O
sbr5XMCFZTOjYD9BmQgIJA51N7ZpET4Q2mIjxZh/pn1uI7NDyqILtnb3P+H0TIFg
SBz9UKafCviXzDlSF9xIaYAW1o1r0xhDP6uZbatPsB+OO4klNB8Q0NdDTW7FDBA=
=Xuxk
-----END PGP SIGNATURE-----

--=-XzlIarNTvWIS6Hg8i4WP--

