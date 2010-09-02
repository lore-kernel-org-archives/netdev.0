From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] drivers/net : avoid some skb->ip_summed
 initializations
Date: Thu, 02 Sep 2010 13:08:01 -0700 (PDT)
Message-ID: <20100902.130801.232752770.davem@davemloft.net>
References: <1283454780.3699.22.camel@edumazet-laptop>
	<20100902.123801.102553189.davem@davemloft.net>
	<1283457301.3699.117.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33178
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752773Ab0IBUHo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 16:07:44 -0400
In-Reply-To: <1283457301.3699.117.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Sep 2010 21:55:01 +0200

> Le jeudi 02 septembre 2010 =E0 12:38 -0700, David Miller a =E9crit :
>=20
>> Respin with #1 please, thanks.
>=20
> Sure !
>=20
> [PATCH] drivers/net : avoid some skb->ip_summed initializations

Thanks Eric, applied.
