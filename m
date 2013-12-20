From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: fix a regression in
 tcf_proto_lookup_ops()
Date: Fri, 20 Dec 2013 16:30:56 -0500 (EST)
Message-ID: <20131220.163056.1860063918856296179.davem@davemloft.net>
References: <CAM_iQpV+WJdeOHOyGENT2XWn=ytjBirBo1G4H2b_QziKHWFw0g@mail.gmail.com>
	<1387570492.19078.463.camel@edumazet-glaptop2.roam.corp.google.com>
	<52B4A6F4.6050702@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab3LTVa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 16:30:59 -0500
In-Reply-To: <52B4A6F4.6050702@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 20 Dec 2013 15:22:12 -0500

> On 12/20/13 15:14, Eric Dumazet wrote:
> 
>> This will be a separate patch, as the faulty commit is different.
>> ( 1f747c26c48bb290c79c34e155860c7e2ec3926a net_sched: convert
>> tc_action_ops to use struct list_head)
>>
> 
> Ok, I hope Dave pulls those changes in - plan to pay closer attention
> over the weekend.

I will.
