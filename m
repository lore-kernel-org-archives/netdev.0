From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 04 May 2007 23:22:28 +0200
Message-ID: <1178313748.7408.41.camel@johannes.berg>
References: <D5C1322C3E673F459512FB59E0DDC32902CA58E7@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-UuAeHQZZdwRiyPzwZAAa"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	hadi@cyberus.ca, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37603 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140AbXEDVVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 17:21:20 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902CA58E7@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-UuAeHQZZdwRiyPzwZAAa
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-05-04 at 13:43 -0700, Waskiewicz Jr, Peter P wrote:
> If hardware exists that wants the granularity to
> start/stop queues independent of each other and continue to have
> traffic
> flow, I really think it should be able to do that.=20

Not much of an if there, I'm pretty sure at least some wireless hardware
can do that. We've been watching this multiqueue stuff for a while now
with some interest but haven't hashed out yet how we could use it.

johannes

--=-UuAeHQZZdwRiyPzwZAAa
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGO6QU/ETPhpq3jKURAlKiAJ92Kog4351Bt33lRPo08M/BGPLa1QCdEGyw
20ksK8cHqPBfzYF6AANRUpc=
=z6pH
-----END PGP SIGNATURE-----

--=-UuAeHQZZdwRiyPzwZAAa--

