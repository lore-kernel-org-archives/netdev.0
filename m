From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: extend device features
Date: Sun, 30 Dec 2012 02:32:59 -0800 (PST)
Message-ID: <20121230.023259.1293618471474381191.davem@davemloft.net>
References: <1356789203.21409.3923.camel@edumazet-glaptop>
	<CAHXqBFL+Ycw4-_LRcOCT0bjhALE3HfVMB7YfcoCruu=zW5PN-g@mail.gmail.com>
	<1356834370.21409.6234.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, avagin@parallels.com, netdev@vger.kernel.org,
	vvs@parallels.com, mirq-linux@rere.qmqm.pl
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab2L3KdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 05:33:00 -0500
In-Reply-To: <1356834370.21409.6234.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <erdnetdev@gmail.com>
Date: Sat, 29 Dec 2012 18:26:10 -0800

> From: Eric Dumazet <edumazet@google.com>
>=20
> veth is lacking most modern facilities, like SG, checksums, TSO.
>=20
> It makes sense to extend dev->features to get them, or GRO aggregatio=
n
> is defeated by a forced segmentation.
>=20
> Reported-by: Andrew Vagin <avagin@parallels.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
