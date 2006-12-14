From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2.6.19-git19] BUG due to bad argument to
	ieee80211softmac_assoc_work
Date: Thu, 14 Dec 2006 16:06:40 +0100
Message-ID: <1166108800.3161.11.camel@johannes.berg>
References: <5b8e20700612131017n1cd8aff3qbe41351435427e25@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-1dJt2Ny4W+ooYdMe3982"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53232 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932820AbWLNPsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 10:48:08 -0500
To: Michael Bommarito <mjbommar@umich.edu>
In-Reply-To: <5b8e20700612131017n1cd8aff3qbe41351435427e25@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1dJt2Ny4W+ooYdMe3982
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-12-13 at 13:17 -0500, Michael Bommarito wrote:

> Attached is a patch that fixes this (the actual change is two lines
> but context provided in patch for review).  The dmesg containing call
> trace is attached to the bugzilla entry above.

You forgot to attach the patch but IIRC it's been found and fixed
already.

johannes

--=-1dJt2Ny4W+ooYdMe3982
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD4DBQBFgWiA/ETPhpq3jKURAmMKAJjs76OLuHAEKBoOBR7cP6z3pmcGAJ0WXjAC
VXTTqCmp2EiE/QlQhyqkSw==
=I/8J
-----END PGP SIGNATURE-----

--=-1dJt2Ny4W+ooYdMe3982--

