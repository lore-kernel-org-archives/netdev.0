From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP : use LIMIT_NETDEBUG in tcp_retransmit_timer()
Date: Tue, 05 Jun 2007 00:15:32 -0700 (PDT)
Message-ID: <20070605.001532.21927821.davem@davemloft.net>
References: <4663BBA4.70009@cosmosbay.com>
	<20070605.000027.59657229.davem@davemloft.net>
	<46650BAE.9070301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754323AbXFEHPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 03:15:17 -0400
In-Reply-To: <46650BAE.9070301@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 05 Jun 2007 09:07:26 +0200

> Should I try to contact 222.39.111.164 and kindly ask him not to trigger this 
> annoying message ?
> 
> Is this remote peer running an old linux, or is it a bug in the current 
> linux-2.6.22-rc4 kernel that my server runs ?

Grrr, yeah it's their end.  And because it's in China with no reverse
DNS your chances of getting them to fix this are between slim and
none.

I'll add your patch, thanks a lot.
