From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev/phy: skip disabled mdio-mux nodes
Date: Tue, 14 Aug 2012 14:16:07 -0700 (PDT)
Message-ID: <20120814.141607.65849990804791086.davem@davemloft.net>
References: <CAOZdJXUB7jLZ_p3TmOs+p=jQM4Xs0a=HUdFia5N46M--LYyXJg@mail.gmail.com>
	<20120814.140736.812697309119422215.davem@davemloft.net>
	<502ABF2A.9070605@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.daney@cavium.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432Ab2HNVQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:16:08 -0400
In-Reply-To: <502ABF2A.9070605@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Tue, 14 Aug 2012 16:12:10 -0500

> David Miller wrote:
> 
>>> Any chance this patch can get into 3.6?  I don't know if it qualifies
>>> as a fix or not, but getting it into 3.6 would make it easier for me
>>> to apply other patches to the powerpc tree.
>>>
>> 
>> I want you to implement it the way David Daney said to do so.
> 
> So you're saying that you don't want this fixed for 3.6?  Because David
> Daney's suggestion would require me to introduce a new device tree
> function, and that won't be accepted until 3.7 at the earliest.

If it is infrastrucure needed to fix a bug, it would be accepted.  Stop
talking nonsense.
