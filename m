From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bcm43xx: Fix for oops on resume
Date: Wed, 07 Feb 2007 14:56:06 +0100
Message-ID: <1170856566.6798.42.camel@johannes.berg>
References: <45c8bd59.oamnvaNRMZvKoPBa%Larry.Finger@lwfinger.net>
	 <1170850549.6798.22.camel@johannes.berg>  <45C9D2E1.7040906@lwfinger.net>
	 <1170855150.6798.38.camel@johannes.berg>  <45C9D930.5010307@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-R/A4r1pYT2q7E3qWbCQS"
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, linux-wireless@vger.kernel.org
To: Larry Finger <larry.finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60570 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161316AbXBGN7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 08:59:08 -0500
In-Reply-To: <45C9D930.5010307@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-R/A4r1pYT2q7E3qWbCQS
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-02-07 at 07:50 -0600, Larry Finger wrote:

> Could you please apply this patch and tell me what gets printed after you=
 resume, and whether you
> did a suspend to RAM or disk?

Oh and if anyone else does this please also let us know what it prints
on a regular freshly booted modprobe.

johannes

--=-R/A4r1pYT2q7E3qWbCQS
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFydp2/ETPhpq3jKURAjG5AJ90t2l0mjc5nqn7ZQkgu5Q3P977JgCfYE2g
dIri/oeJbkMw444+Vu1g4fg=
=7abD
-----END PGP SIGNATURE-----

--=-R/A4r1pYT2q7E3qWbCQS--

