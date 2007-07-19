From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 0/3] dynamic generic netlink multicast
Date: Thu, 19 Jul 2007 12:39:31 +0200
Message-ID: <1184841571.3894.21.camel@johannes.berg>
References: <20070717122706.899784000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-n7HOu161w471nWup4JrG"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58073 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbXGSKjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 06:39:41 -0400
In-Reply-To: <20070717122706.899784000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-n7HOu161w471nWup4JrG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Oh, this patchset triggers a current bug in slub, see:

http://article.gmane.org/gmane.linux.kernel/556887

I forgot mentioning that yesterday, I hope it's not causing any trouble.
Also, I had expected it to be fixed soonish, but can't see that it is.

johannes

--=-n7HOu161w471nWup4JrG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGnz9j/ETPhpq3jKURApp5AJ4wQ2sZLNxLwaE+M1I0EvaoIOjG8wCeICPG
1QaoDK4QSYWsmEDkpWB2TM0=
=XsM9
-----END PGP SIGNATURE-----

--=-n7HOu161w471nWup4JrG--

