From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from
 tc_action_ops
Date: Sat, 14 Dec 2013 22:26:07 -0500 (EST)
Message-ID: <20131214.222607.1156830660558607966.davem@davemloft.net>
References: <52ABC975.2070308@mojatatu.com>
	<20131214.001529.1872893184686335778.davem@davemloft.net>
	<52AC4D82.5070505@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, David.Laight@aculab.com,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575Ab3LOD0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 22:26:09 -0500
In-Reply-To: <52AC4D82.5070505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sat, 14 Dec 2013 07:22:26 -0500

> On 12/14/13 00:15, David Miller wrote:
> 
>> It is significantly different.
>>
>> It is an internal kernel interface that was never used.
> 
> It is not an internal API, Dave.
> It an external kernel module API that has been visible for many years.

There are no stable kernel APIs, I'm sorry if this is news to
you.

Documentation/stable_api_nonsense.txt
