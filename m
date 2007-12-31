From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 0/4] New interface for memory accounting (take 1)
Date: Mon, 31 Dec 2007 14:03:57 -0500
Message-ID: <47793D1D.5050001@redhat.com>
References: <47775B25.7020401@redhat.com> <20071230.233413.117211235.davem@davemloft.net> <47790811.9080004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, tyasui@redhat.com,
	mhiramat@redhat.com, satoshi.oshima.fk@hitachi.com,
	billfink@mindspring.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com, haoki@redhat.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbXLaTFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 14:05:15 -0500
In-Reply-To: <47790811.9080004@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Hi David
> 
> Could you add the following patch, because it apparently was lost
> during the battle :)
> 
> Thank you
> 
> [PATCH] use SK_MEM_QUANTUM_SHIFT in __sk_mem_reclaim()
> 
> Avoid an expensive divide (as done in commit
> 18030477e70a826b91608aee40a987bbd368fec6 but lost in commit
> 23821d2653111d20e75472c8c5003df1a55309a8)

Hello Eric,

Thank you for catching this. I'm sorry about the lost.

Best regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
