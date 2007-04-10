From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 11:18:54 +0200
Message-ID: <1176196734.8459.74.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>
	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>
	 <1176184028.8459.58.camel@johannes.berg>  <461B4242.1040602@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HpJzC18nhz+R1v8q1fPM"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49430 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965111AbXDJJSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 05:18:35 -0400
In-Reply-To: <461B4242.1040602@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HpJzC18nhz+R1v8q1fPM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-04-10 at 09:52 +0200, Patrick McHardy wrote:

> Shouldn't be a problem either. Creating the device atomically also
> prevents that anything else is setting them UP before they're fully
> configured.

How would you do it generically then? I'm absolutely not opposed to the
idea but for now haven't seen how to do it.

johannes

--=-HpJzC18nhz+R1v8q1fPM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGG1Z9/ETPhpq3jKURAneQAJsF05l34ljwloX8q9PnYzVgITjMfgCdH9VU
aYJT7Sspsj5DynrBVOmaxB4=
=FmzM
-----END PGP SIGNATURE-----

--=-HpJzC18nhz+R1v8q1fPM--

