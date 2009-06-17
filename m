From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: refactor multicast/unicast address list
Date: Wed, 17 Jun 2009 14:58:18 +0200
Message-ID: <1245243498.31588.6.camel@johannes.local>
References: <1244889678.13033.6.camel@johannes.local>
	 <1244896094.13033.8.camel@johannes.local>
	 <20090616111842.GG3521@psychotron.englab.brq.redhat.com>
	 <1245151771.9256.3.camel@johannes.local>
	 <20090616123808.GK3521@psychotron.englab.brq.redhat.com>
	 <1245193788.21287.66.camel@johannes.local>
	 <20090617072100.GA3492@psychotron.englab.brq.redhat.com>
	 <1245231024.19769.0.camel@johannes.local>
	 <20090617122616.GB2791@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-2IiJcVAdmPXEmDS8SIyd"
Cc: Jiri Pirko <jpirko@redhat.com>, Netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	davem <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33488 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbZFQM6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 08:58:52 -0400
In-Reply-To: <20090617122616.GB2791@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2IiJcVAdmPXEmDS8SIyd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-17 at 08:26 -0400, John W. Linville wrote:
> On Wed, Jun 17, 2009 at 11:30:24AM +0200, Johannes Berg wrote:
> > On Wed, 2009-06-17 at 09:21 +0200, Jiri Pirko wrote:
> >=20
> > > >I guess we could stick this one into wireless-testing, and then take=
 it
> > > >out again once your patch hits the tree and offers me similar API fo=
r
> > > >list_head based multicast lists?
> > >=20
> > > Or wait, I hope the patch will be ready in week tops.
> >=20
> > Yeah, that's fine, I'll ask people to throw in the simple export patch
> > for testing. Thanks for considering! Please disregard my work on
> > mac80211, I'll rebase over your work.
>=20
> If you need Jiri's patch in wireless-testing I can make arrangements
> to cherry-pick it.

Not the one he just sent, that one's concerned with unicast address
lists. We'll see. The mdev removal still had a bunch of issues anyway.

johannes

--=-2IiJcVAdmPXEmDS8SIyd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOOhlAAoJEODzc/N7+QmaAWMP/A1L5cKHWTRiWJrzfvOoctK8
YRT0y/0fHE0X82sToBk+rnXe8f4MY0amFn6Gyi02ZazrdHwYcBpogicnGj40o3vw
PYyQ4X3nsee4iY+D8bZ5863jYFeBHDXnfOPkfwmJuRW0EGftx+u5yugtrIsneete
DlqX65z8tJwHc8zHTaXAVZJ7c6dGVEOUSyUvLI1Zl3upQmANtKSv8XfX/fMNGKx1
MMyQF0Ma0+aguEwdtaRs/5/t+V3hxuuNeXSKVGre8e3FK5GliPem0bni8gBoDQTB
wRLTwP0cd2Ad4PJaaEjVzY1ZG2/gNJnR9vgljQmoQwlmra2W9XdIjddsooOsY0I1
c4aYkp/2REIY7nEid0+vjpU2f5fDU5SeHhXboTAxupWh+Ht93y7BQAyNx7xIGu2p
YHxAD+ugNDJ+HYDmXG7Qd4P1dGIHQoJfXsG9Xd84VMhE0hcUnLqop5nTJxrMs9g7
pwtbT37nKrgvz0Dt7njY0KKZG5CitXeO+rTjUSEAoGc+sMXPIEmZHH5bHTCUAQWj
jwA8MyVLudnVAiFp2E8j7v+gi8zIzSxYo4g04bPbz9G5kbksqroXYGHmNcGG1Viu
4EIY/gVrheQG6DObUMyqlRybPmPdap4eeBIRzxcyB3iVvhx80cnUptkqurRC0Y9Z
Sw4lnpXlo7I4ir7L5ra3
=hWxz
-----END PGP SIGNATURE-----

--=-2IiJcVAdmPXEmDS8SIyd--

