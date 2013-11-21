From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at net/core/skbuff.c:2839 RIP [<ffffffff819109a2>]
 skb_segment+0x6b2/0x6d0
Date: Thu, 21 Nov 2013 13:17:41 -0500 (EST)
Message-ID: <20131121.131741.737292941735802990.davem@davemloft.net>
References: <1287049824.20131117201744@eikelenboom.it>
	<1392359825.20131121130027@eikelenboom.it>
	<1385043004.10637.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@eikelenboom.it, edumazet@google.com, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702Ab3KUSRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:17:42 -0500
In-Reply-To: <1385043004.10637.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Nov 2013 06:10:04 -0800

> As mentioned earlier, this problem is known and a patch is under review.
> 
> http://marc.info/?l=linux-netdev&m=138419594024851&w=2

It seems this patch still requires some improvements, can you guys sort
out what needs to be done so that I can apply a fix soon?

Thanks!
