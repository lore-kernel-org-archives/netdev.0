From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Generic netlink interface help
Date: Thu, 24 May 2007 18:34:37 +0200
Message-ID: <1180024477.18003.11.camel@johannes.berg>
References: <84po8XY4.1179999810.5490870.samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-AqHhNk28XktRItvY8xZl"
Cc: giometti@enneenne.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42055 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761357AbXEYJwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 05:52:37 -0400
In-Reply-To: <84po8XY4.1179999810.5490870.samuel@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-AqHhNk28XktRItvY8xZl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-05-24 at 09:43 +0000, Samuel Ortiz wrote:

> You probably want to use the libnl library. The latest SVN code has
> support for generic netlink:
> http://people.suug.ch/~tgr/libnl/

Huh. I just looked at it and I don't understand anything. What's the
point with genl_register/genl_unregister and having a table of commands
etc? Thomas, can you explain how I should use libnl for nl80211 now? I
mean, I can see what I can do with just sending/receiving messages but
it feels like I'm missing something with all that other infrastructure
in libnl.

johannes

--=-AqHhNk28XktRItvY8xZl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGVb6c/ETPhpq3jKURAjeaAKClDgwAz32yqhUMZtSl+HyIIh38nQCcCcD4
ybMr9Vc7IF357u9IkVXDAac=
=XcPZ
-----END PGP SIGNATURE-----

--=-AqHhNk28XktRItvY8xZl--

