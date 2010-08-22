From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Sun, 22 Aug 2010 00:39:57 -0700 (PDT)
Message-ID: <20100822.003957.59669197.davem@davemloft.net>
References: <20100821.230309.104050634.davem@davemloft.net>
	<E1On4oL-0008EI-00.xeb-mail-ru@f230.mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751698Ab0HVHjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 03:39:40 -0400
In-Reply-To: <E1On4oL-0008EI-00.xeb-mail-ru@f230.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kozlov <xeb@mail.ru>
Date: Sun, 22 Aug 2010 11:17:45 +0400

>> From: David Miller <davem@davemloft.net>
>> Date: Sat, 21 Aug 2010 23:01:29 -0700 (PDT)
>> 
>> Ugh, I'll fix this up, but after _8_, yes _EIGHT_, iterations of this
>> patch set the amount of problems that remain is completely
>> unbelievable.
> 
> Sorry, maybe it is wrong, but i did patch using repository git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git, HEAD at a63ecd835f075b21d7d5cef9580447f5fbb36263.
> Have i update and resend it for net-next-2.6 ?

I said "I'll fix this up" which means I'll take care of everything.

You should always make all patches against the tree that it will be
applied to.
