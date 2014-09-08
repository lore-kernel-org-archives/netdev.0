From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix skb_page_frag_refill() kerneldoc
Date: Mon, 08 Sep 2014 14:13:14 -0700 (PDT)
Message-ID: <20140908.141314.1584304441141796959.davem@davemloft.net>
References: <1410174000.11872.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<540D8D3C.9080202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160AbaIHVNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:13:15 -0400
In-Reply-To: <540D8D3C.9080202@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 08 Sep 2014 15:04:28 +0400

>> - * @prio: priority for memory allocation
>> + * @gfp: priority for memory allocation
> 
>    'gfp' is not priority, it's just flags.

It is an allocation priority, and I've seen that terminology used for
2 decades.
