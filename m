From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Wed, 09 May 2007 16:16:47 +0200
Message-ID: <1178720207.3806.5.camel@johannes.berg>
References: <D5C1322C3E673F459512FB59E0DDC32902CA58E7@orsmsx414.amr.corp.intel.com>
	 <1178313748.7408.41.camel@johannes.berg>
	 <1178616837.3385.85.camel@debian.sh.intel.com>
	 <1178617538.18162.54.camel@johannes.berg>
	 <1178630917.4078.46.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-EAT3ZqRlLvJZtcRqSlP0"
Cc: Zhu Yi <yi.zhu@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34216 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbXEIOOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 10:14:45 -0400
In-Reply-To: <1178630917.4078.46.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-EAT3ZqRlLvJZtcRqSlP0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-05-08 at 09:28 -0400, jamal wrote:

> Those virtual devices you have right now. They are a hack that needs to
> go at some point.

Actually, if we're talking about mac80211, the "master" device we have
that does the qos stuff must go, but the other virtual devices need to
stay for WDS/AP and a lot of other combinations. Just to clear up some
possible confusion.

johannes

--=-EAT3ZqRlLvJZtcRqSlP0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGQdfP/ETPhpq3jKURAtCfAJ99XcAQ4373wftZiVfsQ8N7eLIqPQCfRvKk
UhqyCeAlrtpf0u3x4It42/M=
=cbnB
-----END PGP SIGNATURE-----

--=-EAT3ZqRlLvJZtcRqSlP0--

