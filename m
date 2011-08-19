From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add the comment for skb->l4_hash
Date: Fri, 19 Aug 2011 07:27:57 -0700 (PDT)
Message-ID: <20110819.072757.1262017366945258503.davem@davemloft.net>
References: <20110819.071918.2148980329707419757.davem@davemloft.net>
	<CABa6K_G+cv3z-WoFSu3s017uVa54aHcn_D=R6WX3=-YA2o2j8g@mail.gmail.com>
	<20110819.072547.515057198170181830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805Ab1HSO2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 10:28:01 -0400
In-Reply-To: <20110819.072547.515057198170181830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 19 Aug 2011 07:25:47 -0700 (PDT)

> From: Changli Gao <xiaosuo@gmail.com>
> Date: Fri, 19 Aug 2011 22:22:24 +0800
> 
>> On Fri, Aug 19, 2011 at 10:19 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Changli Gao <xiaosuo@gmail.com>
>>> Date: Fri, 19 Aug 2011 22:14:12 +0800
>>>
>>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>>
>>> It was obvious to me this time, but please in the future indicate in
>>> "[PATCH]" that a change is targetted for net-next as this one was.
>>>
>>> Applied, thanks.
>>>
>> 
>> Sorry again. Please apply the new one instead, as I made a typo
>> mistake in the previous two patches. Thanks.
> 
> Ok, done.

BTW for next time, "net-next" indication belongs inside of "[]"
brackets, it should look something like:

	Subject: [PATCH net-next] net: blah blah blah

Thanks.
