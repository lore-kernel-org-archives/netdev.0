From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2.6] WE-22 : prevent information leak on 64 bit
Date: Wed, 18 Apr 2007 12:18:11 +0200
Message-ID: <1176891491.6141.63.camel@johannes.berg>
References: <20070323003116.GC2712@bougret.hpl.hp.com>
	 <1175508410.23438.75.camel@johannes.berg>
	 <20070417170820.GB22372@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CrSHNBiciv6FsUBsIlJ3"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33746 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422808AbXDRKPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 06:15:54 -0400
In-Reply-To: <20070417170820.GB22372@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CrSHNBiciv6FsUBsIlJ3
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Jean,

> 	First, I'm the current active maintainer of the
> wext-over-netlink interface, and nobody bothered to even 'inform' me
> about its removal, let alone consult with me.

I definitely should have copied you on the feature-removal schedule
patch for wext-over-netlink and then the actual removal in wireless-dev;
please accept my apologies for not doing that, it was not done in bad
faith. It was never my intention to demote you to a "second class
citizen", I'm sorry you feel that way.

I have previously (and multiple times) given technical justification for
removing this code (even recorded in the kernel changelog now) and I
contend your allegation that it is a political issue. Others in this
thread have pointed out the technical issues with wext and wext/nl so I
will not repeat them.

I hope that despite my mistakes in handling the wext/nl removal we will
be able to work together in the future to have wext fully supported with
clear semantics for backwards compatibility while the kernel internally
migrates towards cfg80211.

johannes

--=-CrSHNBiciv6FsUBsIlJ3
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGJfBi/ETPhpq3jKURAmQwAKCnkstoiNfYGyE6NocnCIISsRHiIACfTPzm
Vx24BYZqnoPVGRm8qiu3Hek=
=DqGm
-----END PGP SIGNATURE-----

--=-CrSHNBiciv6FsUBsIlJ3--

