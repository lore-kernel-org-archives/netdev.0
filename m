From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 13:24:57 +0200
Message-ID: <1176204297.8459.86.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>
	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>
	 <1176184028.8459.58.camel@johannes.berg>  <461B4242.1040602@trash.net>
	 <1176196734.8459.74.camel@johannes.berg>  <461B5E42.2030900@trash.net>
	 <1176200879.8459.77.camel@johannes.berg>  <461B6B22.3090009@trash.net>
	 <1176202930.8459.81.camel@johannes.berg>  <461B7060.8000407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-jOJqixZacfI1IIxZ1kJV"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38883 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932203AbXDJLY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 07:24:29 -0400
In-Reply-To: <461B7060.8000407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jOJqixZacfI1IIxZ1kJV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-04-10 at 13:09 +0200, Patrick McHardy wrote:

> I know :) It was a few month ago when I noticed the new bonding
> sysfs interface when I first thought that we really need this.

:)

> > I don't think wireless can get away without a new tool. So much stuff
> > there. Look at
> > http://git.kernel.org/?p=3Dlinux/kernel/git/linville/wireless-dev.git;a=
=3Dblob;f=3Dinclude/linux/nl80211.h;hb=3DHEAD
>=20
>=20
> Maybe not wireless, but bonding, briding, vlan, etun, possibly more.

Fair enough. Then the question however remains whether wireless should
try to do all things it needs in one or try leveraging multiple things
from other places. Thoughts?

johannes

--=-jOJqixZacfI1IIxZ1kJV
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGG3QI/ETPhpq3jKURAm3TAJwLC7MLIYwyXqb6Eq8Sb4PW8nEqRwCffBYY
2s2GCzFDVvGeJBFXto+VbaI=
=tCnS
-----END PGP SIGNATURE-----

--=-jOJqixZacfI1IIxZ1kJV--

