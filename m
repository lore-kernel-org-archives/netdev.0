From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 22:03:54 +0200
Message-ID: <1176149034.8459.36.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-NOhn081qnCN4LO5xwpa5"
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	akpm@linux-foundation.org, dim@openvz.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:44997 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965418AbXDIUDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 16:03:50 -0400
In-Reply-To: <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-NOhn081qnCN4LO5xwpa5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-04-09 at 13:35 -0600, Eric W. Biederman wrote:
>=20
> Nor have I seen a rigorous adherence to all new network configuration
> using netlink.  The wireless code doesn't even seem to really try.

You're talking about the wext stuff that was invented ten years ago.
cfg80211/nl80211 which I was talking about actually does use netlink
almost exclusively (and you can add virtual interfaces using netlink)
but we also provided some easy sysfs attributes.

johannes

--=-NOhn081qnCN4LO5xwpa5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGGpwq/ETPhpq3jKURAskCAJ4iCjFq79TFXtYk37AHG+ZxSUN06wCgjI3O
M0ifCCiWwamNFihJIFARRCc=
=5cWN
-----END PGP SIGNATURE-----

--=-NOhn081qnCN4LO5xwpa5--

