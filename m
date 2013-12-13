From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from
 tc_action_ops
Date: Fri, 13 Dec 2013 18:21:51 -0500 (EST)
Message-ID: <20131213.182151.701953060874571927.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7489@saturn3.aculab.com>
	<CAM_iQpVgo+nxN3eTRg_F9u+-k4ML+D3ZqsrAEOeLZwtU6dOk3g@mail.gmail.com>
	<52AB7BC6.9050503@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, David.Laight@aculab.com,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131Ab3LMXVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 18:21:53 -0500
In-Reply-To: <52AB7BC6.9050503@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 13 Dec 2013 16:27:34 -0500

> On 12/13/13 13:33, Cong Wang wrote:
> 
>> Why? Keep in mind that we don't need to worry about any
>> out-of-tree modules. :)
> 
> This is an API that is used to export additional stats that
> are not generic.

Nobody implements it.

When someone does, add it back.

End of discussion.
