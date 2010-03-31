From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/3] bridge br_multicast: Make functions
 less ipv4 dependent.
Date: Tue, 30 Mar 2010 23:24:29 -0700 (PDT)
Message-ID: <20100330.232429.12896139.davem@davemloft.net>
References: <201003291101.o2TB1R0W006599@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48921
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757676Ab0CaGY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:24:27 -0400
In-Reply-To: <201003291101.o2TB1R0W006599@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Mon, 29 Mar 2010 20:01:27 +0900

> Introduce struct br_ip{} to store ip address and protocol
> and make functions more generic so that we can support
> both IPv4 and IPv6 with less pain.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Stephen said he would clean up the macros and he seemed to imply
therefore that he'd resubmit these, so I'll leave patches #2 and #3 to
him.

Thanks!
