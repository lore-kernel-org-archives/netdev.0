From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Sat, 21 Aug 2010 23:01:29 -0700 (PDT)
Message-ID: <20100821.230129.71103230.davem@davemloft.net>
References: <1282383066.2636.16.camel@edumazet-laptop>
	<E1OmmB6-0005es-00.xeb-mail-ru@f299.mail.ru>
	<AANLkTimQwja4qF0X5gzG7u14+aXF_zVVZcwN5bHzku6V@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45182
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751324Ab0HVGBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 02:01:16 -0400
In-Reply-To: <AANLkTimQwja4qF0X5gzG7u14+aXF_zVVZcwN5bHzku6V@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sat, 21 Aug 2010 20:42:09 +0800

> I think the following lines from your patch are also useful, and you'd
> better move them above the "---" marker.

I'll take care of this when applying his patch.

Also this patch was against net-2.6 or even something
earlier, so there were many patch rejects I had to fix
up against include/linux/if_pppox.h when applying this
to net-next-2.6

