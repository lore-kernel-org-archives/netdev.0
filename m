From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Tue, 28 Oct 2008 22:05:36 -0700 (PDT)
Message-ID: <20081028.220536.183082966.davem@davemloft.net>
References: <20081008.114527.189056050.davem@davemloft.net>
	<49077918.4050706@cosmosbay.com>
	<490795FB.2000201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	clameter@sgi.com, a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45195
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751223AbYJ2FF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 01:05:59 -0400
In-Reply-To: <490795FB.2000201@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 28 Oct 2008 23:45:15 +0100

> I will submit a new patch serie tomorrow, with :
> 
> Patch 1 : spinlocks instead of rwlocks, and bug spotted by Christian Bell
> 
> Patch 2 : splited on two parts (2 & 3) , one for IPV4, one for IPV6, 

I very much look forward to this :-)

I like these changes and can't wait to add them to net-next-2.6
