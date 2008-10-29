From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 11:19:20 -0700 (PDT)
Message-ID: <20081029.111920.119224911.davem@davemloft.net>
References: <49081D67.3050502@cosmosbay.com>
	<20081029.015659.223371561.davem@davemloft.net>
	<490838C6.4060304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl, christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45680
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751904AbYJ2STr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:19:47 -0400
In-Reply-To: <490838C6.4060304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 29 Oct 2008 11:19:50 +0100

> [PATCH] udp: udp_get_next() should use spin_unlock_bh()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
