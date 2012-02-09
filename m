From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: more generic L2 header check
Date: Thu, 09 Feb 2012 15:29:43 -0500 (EST)
Message-ID: <20120209.152943.1123862542883793404.davem@davemloft.net>
References: <4F33A3FC.1050205@mellanox.com>
	<20120209.135235.957414875716615693.davem@davemloft.net>
	<CAJZOPZJj=rBoss-JiLm6K66D1h+zyerDspDS+358t7u=Mg2pfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163Ab2BIU3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 15:29:48 -0500
In-Reply-To: <CAJZOPZJj=rBoss-JiLm6K66D1h+zyerDspDS+358t7u=Mg2pfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Thu, 9 Feb 2012 22:04:34 +0200

> On Thu, Feb 9, 2012 at 8:52 PM, David Miller <davem@davemloft.net> wrote:
> 
>> I've fix this now, thanks.
> 
> Yep, I see it there, still, for correctness/biscetion, you should
> rebase such that the order of commits when pushed to Linus is

I cannot rebase my tree, too many people use it and I would break
their stuff.

We simply have to live with this error.
