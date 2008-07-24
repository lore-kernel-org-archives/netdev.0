From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Fri, 25 Jul 2008 01:35:52 +0300
Message-ID: <200807250135.53241.opurdila@ixiacom.com>
References: <200807241922.57361.opurdila@ixiacom.com> <20080724.145600.30988015.davem@davemloft.net> <20080724145811.2d2b9ec6@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1269 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750857AbYGXWiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 18:38:20 -0400
In-Reply-To: <20080724145811.2d2b9ec6@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 July 2008, Stephen Hemminger wrote:

> How hard would it be to add PLL support to use same kind of timestamp.
> Enlist the help of some NTP/clock experts to help.

Let me see if I got this correctly: modify the hardware so that the CPU is 
synchronized with the NIC timestamping unit. If so, I will agree that this is 
the cleanest possible solution. 

Thanks,
tavi
