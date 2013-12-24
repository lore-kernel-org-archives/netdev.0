From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Tue, 24 Dec 2013 12:54:11 -0500 (EST)
Message-ID: <20131224.125411.922163414560760209.davem@davemloft.net>
References: <52B8DF80.2010508@windriver.com>
	<20131224.003125.1848179270970861998.davem@davemloft.net>
	<52B91E21.1050907@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xiyou.wangcong@gmail.com,
	steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492Ab3LXRyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 12:54:15 -0500
In-Reply-To: <52B91E21.1050907@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Tue, 24 Dec 2013 13:39:45 +0800

> 
> 
> On 2013年12月24日 13:31, David Miller wrote:
>> From: Fan Du<fan.du@windriver.com>
>> Date: Tue, 24 Dec 2013 09:12:32 +0800
>>
>>> >  I saw this patch is marked 'Not Applicable' in patchwork.
>> It means that it doesn't go in via my tree directly, it
>> "doesn't apply".
>>
>> Instead, it goes into Steffen's IPSEC tree.
>>
> 
> Thanks for your explanation!!!
> 
> I'm not well understand the curtsy about patchwork, and one last
> question,
> [PATCHv4 net-next 0/8] pktgen IPsec support is tagged as 'Awaiting
> Upstream'
> what does that mean and do I need to take further action about this
> patch set?

It means the same thing, that I expect to receive this change via
upstream, which is Steffen's IPSEC tree.
