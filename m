From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] d80211: don't display name of invisible network
	device
Date: Tue, 30 Jan 2007 14:47:25 +0100
Message-ID: <1170164845.30318.19.camel@johannes.berg>
References: <20070129174809.6401B48499@silver.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-2ooZHFequTbl8OZlMqpD"
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:54962 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965372AbXA3Nsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 08:48:30 -0500
In-Reply-To: <20070129174809.6401B48499@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-2ooZHFequTbl8OZlMqpD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-01-29 at 18:48 +0100, Jiri Benc wrote:
> Invisible master interface does not have meaningful name. Display the wip=
hy
> identifier in kernel messages instead.
>=20
> Also, remove the allocation of master interface name as it is purposeless
> now.

If the master netdev no longer has a name, how can you still use `tc' on
it?

johannes

--=-2ooZHFequTbl8OZlMqpD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFv0xt/ETPhpq3jKURAhZWAJ477bk+KRvGZoEv45krrM63lXoo1QCfWtSr
ValIfeNWX0TgF7nzrx7YHSU=
=TJ8h
-----END PGP SIGNATURE-----

--=-2ooZHFequTbl8OZlMqpD--

