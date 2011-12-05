From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove TCP_OFF and TCP_PAGE macros
Date: Mon, 05 Dec 2011 18:47:24 -0500 (EST)
Message-ID: <20111205.184724.2166829337166026248.davem@davemloft.net>
References: <1323018317.2762.143.camel@edumazet-laptop>
	<1323019253.1785.7.camel@joe2Laptop>
	<1323083235.2670.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932719Ab1LEXr3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 18:47:29 -0500
In-Reply-To: <1323083235.2670.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Dec 2011 12:07:15 +0100

> Le dimanche 04 d=E9cembre 2011 =E0 09:20 -0800, Joe Perches a =E9crit=
 :
>> And maybe the TCP_OFF and TCP_PAGE macros should be removed.
>>=20
>=20
> Agreed, thanks.
>=20
> [PATCH net-next] tcp: remove TCP_OFF and TCP_PAGE macros
>=20
> As mentioned by Joe Perches, TCP_OFF() and TCP_PAGE() macros are
> useless.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
