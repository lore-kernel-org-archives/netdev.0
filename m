From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Tue, 08 May 2007 11:45:38 +0200
Message-ID: <1178617538.18162.54.camel@johannes.berg>
References: <D5C1322C3E673F459512FB59E0DDC32902CA58E7@orsmsx414.amr.corp.intel.com>
	 <1178313748.7408.41.camel@johannes.berg>
	 <1178616837.3385.85.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-FNQF8PP8W5XMUkYcnX77"
Cc: jamal <hadi@cyberus.ca>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:39940 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966194AbXEHJni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 05:43:38 -0400
In-Reply-To: <1178616837.3385.85.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-FNQF8PP8W5XMUkYcnX77
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Somehow I didn't see the mails inbetween. Let me think.

On Tue, 2007-05-08 at 17:33 +0800, Zhu Yi wrote:

> Jamal, as you said, the wireless subsystem uses an interim workaround
> (the extra netdev approach) to achieve hardware packets scheduling. But
> with Peter's patch, the wireless stack doesn't need the workaround
> anymore. This is the actual fix.

Actually, we still need multiple devices for virtual devices? Or which
multiple devices are you talking about here?

johannes

--=-FNQF8PP8W5XMUkYcnX77
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGQEbC/ETPhpq3jKURAiC2AKCmOysevErQGPor4TAI/OSy4evwyACgtQdF
fsMcpH7+RyAY+TvBpFBwF/c=
=VdFY
-----END PGP SIGNATURE-----

--=-FNQF8PP8W5XMUkYcnX77--

