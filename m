From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at net/core/skbuff.c:2839 RIP [<ffffffff819109a2>]
 skb_segment+0x6b2/0x6d0
Date: Thu, 21 Nov 2013 13:38:24 -0500 (EST)
Message-ID: <20131121.133824.1318844228024646798.davem@davemloft.net>
References: <1385043004.10637.34.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131121.131741.737292941735802990.davem@davemloft.net>
	<1385058216.10637.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux@eikelenboom.it,
	edumazet@google.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787Ab3KUSi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:38:26 -0500
In-Reply-To: <1385058216.10637.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Nov 2013 10:23:36 -0800

> I was planning to resend Herbert patch today anyway, after a new round
> of testing on my hosts.

Please do, it would be nice to have your tested-by or similar tag on
it at least.

Thanks!
