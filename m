From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
 jiffies in htb_dequeue()
Date: Wed, 10 Dec 2008 15:38:20 +0100
Message-ID: <493FD45C.7030503@trash.net>
References: <20081209144534.GC15353@ff.dom.local> <20081209.223545.196224587.davem@davemloft.net> <20081210091126.GA4707@ff.dom.local> <20081210.011431.203551043.davem@davemloft.net> <20081210093532.GA7926@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62709 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbYLJOiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 09:38:23 -0500
In-Reply-To: <20081210093532.GA7926@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Dec 10, 2008 at 01:14:31AM -0800, David Miller wrote:
>   
>
>> I understand it's logical steps, but you could just do 1 and
>> 2 in the same patch and it'd be OK.
>>     
>
> OK, so I withdraw 1 and 4 too, and let's say this is No 7 (2in1).
>   


Just FYI, I'm travelling today, so I'll need until tommorrow to
review this.

