From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Tue, 19 Mar 2013 17:56:12 -0400 (EDT)
Message-ID: <20130319.175612.1450380502469601673.davem@davemloft.net>
References: <20130319142141.5d32cae2@nehalam.linuxnetplumber.net>
	<20130319.172645.2081434694692631052.davem@davemloft.net>
	<CALnjE+ryZpcfev4xDQ8dcnrxFqXFjjxvnnxN_dU35gu_KEk86g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754782Ab3CSV4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 17:56:15 -0400
In-Reply-To: <CALnjE+ryZpcfev4xDQ8dcnrxFqXFjjxvnnxN_dU35gu_KEk86g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Tue, 19 Mar 2013 14:38:11 -0700

> On Tue, Mar 19, 2013 at 2:26 PM, David Miller <davem@davemloft.net> wrote:
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Tue, 19 Mar 2013 14:21:41 -0700
>>
>>> Doesn't build with this patch alone (ie. not bisectable).
>>>
>>>   CC [M]  net/ipv6/ip6_gre.o
>>> net/ipv6/ip6_gre.c:41:27: fatal error: net/ip_tunnel.h: No such file or directory
>>> compilation terminated.
>>
>> Oh well, too late, it's all already in my tree.
> 
> sorry about that.
> I am sending update patch soon.

There is nothing for you to send, what's in my tree is not changing.
