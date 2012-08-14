From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] netdev/phy: skip disabled mdio-mux nodes
Date: Tue, 14 Aug 2012 16:12:10 -0500
Message-ID: <502ABF2A.9070605@freescale.com>
References: <1344358266-5450-1-git-send-email-timur@freescale.com> <CAOZdJXUB7jLZ_p3TmOs+p=jQM4Xs0a=HUdFia5N46M--LYyXJg@mail.gmail.com> <20120814.140736.812697309119422215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <david.daney@cavium.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:33552
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754432Ab2HNVMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:12:16 -0400
In-Reply-To: <20120814.140736.812697309119422215.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>> Any chance this patch can get into 3.6?  I don't know if it qualifies
>> as a fix or not, but getting it into 3.6 would make it easier for me
>> to apply other patches to the powerpc tree.
>>
> 
> I want you to implement it the way David Daney said to do so.

So you're saying that you don't want this fixed for 3.6?  Because David
Daney's suggestion would require me to introduce a new device tree
function, and that won't be accepted until 3.7 at the earliest.

> And you never need to ask me questions like this, I clearly mark the
> state of your patch:
> 
> http://patchwork.ozlabs.org/patch/175750/
> 
> So that you can just monitor it instead of wasting my time asking what
> is happening to your patch.

Sorry.

> Time of mine you consume forcing me to reply to you in situations like
> this, which you could handle on your own, is time that I can't spend
> reviewing patches from oher people that really are ready to go into
> the tree.
> 


-- 
Timur Tabi
Linux kernel developer at Freescale
