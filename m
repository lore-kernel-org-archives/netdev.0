From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp_md5_hash_skb_data() frag_list handling
Date: Mon, 31 May 2010 00:30:23 -0700 (PDT)
Message-ID: <20100531.003023.39160973.davem@davemloft.net>
References: <20100517.231403.148532542.davem@davemloft.net>
	<1274164851.2567.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54286
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756438Ab0EaHaO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 03:30:14 -0400
In-Reply-To: <1274164851.2567.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 May 2010 08:40:51 +0200

> Le lundi 17 mai 2010 =E0 23:14 -0700, David Miller a =E9crit :
>> Eric, would you please formally submit that tcp md5 fraglist
>> fix to net/ipv4/tcp.c with proper signoffs?
>=20
> Here it is, thanks !
>=20
>=20
> [PATCH] tcp: tcp_md5_hash_skb_data() frag_list handling
>=20
> tcp_md5_hash_skb_data() should handle skb->frag_list, and eventually
> recurse.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
