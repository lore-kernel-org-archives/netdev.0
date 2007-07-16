From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 0/3] netlink/generic netlink multicast group rework
Date: Mon, 16 Jul 2007 10:48:31 +0200
Message-ID: <1184575711.15112.3.camel@johannes.berg>
References: <20070704143037.495786000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tv4vV8LCq2VAr+2DBsOd"
Cc: hadi@cyberus.ca, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34162 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825AbXGPJgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 05:36:24 -0400
In-Reply-To: <20070704143037.495786000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-tv4vV8LCq2VAr+2DBsOd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-04 at 16:30 +0200, Johannes Berg wrote:
> This is just a repost of the patches that I posted previously
> because they were buried deeply in the ACPI thread and I'm
> hoping that now other people will also take a look.

Ping? Has anybody had a chance to look into this? I've been running
regular work on my notebook with this ever since posting and it all
works fine; the ACPI people would like to see this in to base the ACPI
notification on it. I don't care all that much right now but if they
don't base their acpi notification on it then these patches will need to
be updated to give acpi a stable family/multicast number.

johannes

--=-tv4vV8LCq2VAr+2DBsOd
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGmzDf/ETPhpq3jKURAi9/AJ9kg8bOvrilSX3BI+uqrc5AbQPt7gCgiONF
KWANlC2cN733jufUUoAsCJo=
=c4qk
-----END PGP SIGNATURE-----

--=-tv4vV8LCq2VAr+2DBsOd--

