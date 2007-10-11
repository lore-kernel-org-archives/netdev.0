From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Thu, 11 Oct 2007 11:32:30 +0200
Message-ID: <1192095150.4770.25.camel@johannes.berg>
References: <470B71CD.3000706@openvz.org>
	 <m1przoxk1v.fsf@ebiederm.dsl.xmission.com>
	 <1192041243.4770.8.camel@johannes.berg>
	 <m1wstukasp.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ijyB+Kt37qfPmctWaNeJ"
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47561 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbXJKJce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 05:32:34 -0400
In-Reply-To: <m1wstukasp.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ijyB+Kt37qfPmctWaNeJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-10 at 13:51 -0600, Eric W. Biederman wrote:

> Yes.  Netlink sockets are per-namespace and you can use the namespace
> of a netlink socket to look up a netdev.

Ok, thanks. I still haven't really looked into the wireless vs. net
namespaces problem but this will probably help.

johannes

--=-ijyB+Kt37qfPmctWaNeJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARw3traVg1VMiehFYAQK7Fw/9E6eSdun47bGYVoNPql4yveKHQJaVN+vd
1vVZLntllNSl/z+AdTeejx8MK9kM6HDw6uDg4yb8PGJApz/Ds30N6kVoFSGBIJFS
gHR4coJ/UP1YBwnt9lvrl5LGRQoioYqOUDkpHFXubbZk8oQOL9fuAgU1TILptJ5R
jK8wid5RvszW1+PpMykt0ZHHVpX3TiIjBw2plAVMHTY4KU8Phi35fE0Z2Sa/ky3w
6S/+SfNAWFiZgm8FB/CFQjiIsLOlitUTaGCjPSliQVTxhG4t6zjwg2SZtbB7gaE2
RlkuqOAN3bsjScE38MKB4raUS4/uSs+EIh/XG919XIW1OZjfoecGz/A92ceoqNCT
8C2cndH4ttsPvBYEWIWrTSmpaTko7qawa5glBRh6mqlQhXYRhSJJWO++WYm03QUg
hVX6iMEU6pfMaXpdRI1rcYb/tBJti8I7U+h/5KXrpecEdubf5PFOjs8V0acZoe49
K6YU8yqGjNEXPytkfsYRc8AJMpntt+fVkA32q81Pq00zmTrNYLMb3E4BI7XzLnvu
4YQHw9i7xET1QuOD4wAxOtwzhcPiaI4xkl3ds6nsTVKtBxDCMVBpi/SBi9Z0ifCG
3DNlfWAIAsuTQtihwnjhsdRfrp+291S6k5nDehZq+VPSCo3UYmY9/u7PRRptYwCq
nKloClDzD3s=
=v4nZ
-----END PGP SIGNATURE-----

--=-ijyB+Kt37qfPmctWaNeJ--

