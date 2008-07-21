From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] netns: dont alloc ipv6 fib timer list
Date: Mon, 21 Jul 2008 13:33:37 -0700 (PDT)
Message-ID: <20080721.133337.36896785.davem@davemloft.net>
References: <20080721192920.058840619@vyatta.com>
	<20080721.132601.62660580.davem@davemloft.net>
	<20080721133037.7b904ddb@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37459
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755238AbYGUUdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:33:37 -0400
In-Reply-To: <20080721133037.7b904ddb@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Jul 2008 13:30:37 -0700

> Subject: netns: don't alloc ipv6 fib timer list
> 
> FIB timer list is a trivial size structure, avoid indirection and just
> put it in existing ns.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Bzzt, try again.

error: patch failed: net/ipv6/ip6_fib.c:661
error: net/ipv6/ip6_fib.c: patch does not apply

