From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Wed, 11 Apr 2007 18:59:12 +0200
Message-ID: <1176310753.3826.13.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>
	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>
	 <1176239819.10381.10.camel@johannes.berg>  <461D09AD.9060603@trash.net>
	 <1176309793.3826.7.camel@johannes.berg>  <461D1251.8050709@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-90NYUV/0+KnzFitZgZt2"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48650 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381AbXDKQ6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 12:58:11 -0400
In-Reply-To: <461D1251.8050709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-90NYUV/0+KnzFitZgZt2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-04-11 at 18:52 +0200, Patrick McHardy wrote:

> I'm not sure I'm following. I was under the impression that the
> conclusion of yesterdays discussion was that its probably not
> worth using rtnetlink for wireless so it will continue to use
> generic netlink exclusively, but even if that is wrong, nothing
> would prevent adding a "rtnetlink family" for wireless as well.

Oh, ok. Yeah nothing stops us from doing that, of course.

johannes

--=-90NYUV/0+KnzFitZgZt2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGHRPg/ETPhpq3jKURAtFyAKC0k/cy8o9yAy16XD46kMnoqqc8fQCeMwvl
dWAsf/csVepcXpxEBxb2o/A=
=4D61
-----END PGP SIGNATURE-----

--=-90NYUV/0+KnzFitZgZt2--

