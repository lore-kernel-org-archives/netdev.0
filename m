From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Sat, 06 Oct 2007 10:32:35 +0200
Message-ID: <1191659555.4063.2.camel@johannes.berg>
References: <20071005.031209.57156822.davem@davemloft.net>
	 <20071005084317.52ee7efe@freepuppy.rosehill>
	 <20071005.170428.68050176.davem@davemloft.net>
	 <20071005172801.7f657e81@freepuppy.rosehill>
	 (sfid-20071006_012820_880051_7D3AF35C)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8Yzz4N5rDbqe+ccPDNKh"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com, jeff@garzik.org,
	Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58768 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbXJFIcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2007 04:32:20 -0400
In-Reply-To: <20071005172801.7f657e81@freepuppy.rosehill> (sfid-20071006_012820_880051_7D3AF35C)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8Yzz4N5rDbqe+ccPDNKh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-10-05 at 17:28 -0700, Stephen Hemminger wrote:

> Sparse doesn't like dynamically sized arrays, which is what BUILD_BUG_ON(=
)
> expands into.  Not sure why it is hostile to dynamic arrays,
> probably just a Linus (or Viro) taste thing.

sparse from git copes with it.

johannes

--=-8Yzz4N5rDbqe+ccPDNKh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARwdII6Vg1VMiehFYAQLEhBAAqpKDTAWRlDd27T+EGt7tNmZEib5vGA75
u/0dW4/YzljsNcX22rGb3smTswEaN2eEbqHEnDvm+FU2bKlFs7/gaqjhE0+zd/vU
KcaX08k08HN/bLrJJp3QcemJzsKv1n0UlwbXqTJl8lb+nMbsalRzKUHI6ztuNlGb
iBIchnal4iCrmbKdvpp0DIdlsIZkQstG3SHCN9PbuVZsjj6yu6sw7Ukc8sDE7ov+
10sElrbENJTtJ1/5Ap8E8EFhqq5qJY0Tarn9fc7gflOoOsfUdQ96TqpTRBAsOhr5
R918MrovRBEGMadx5c843kCk/OHNAEBbKCqOhO5tffQRhM44Q+J0yGKb+TASrt+N
bAFypygZLmyU486wSNLcbIAk6iS9+QVJJJqSW60X2P9gUBVyo7fe8k0+TlhiZqMd
Kn4w0QhoEkXIXaNU+iqdgLf82enQ8dZnhZ/QX6qQbAkHDT9oMTW9Lv1woxEw9Ise
qauhKodwNosn86+EO0lyPZYxT4xK8eTThLvzMT5z4BBpoSBucPAxHdWHpVloxWv6
8qAIhgW9NDXHY/lqv4lK2zuQnU28Yy2/ed2U+pucXcn/2aR8v9nGr9Mq0b4PtZws
wREFwgwaHZrY9dZXPpu9f2b3uts8JF65ojkpREVhGU06HkLJMv9x5M0RrgBnQOQb
wa+ltQ6Yvto=
=28cl
-----END PGP SIGNATURE-----

--=-8Yzz4N5rDbqe+ccPDNKh--

