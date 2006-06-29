From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: RDMA will be reverted
Date: Fri, 30 Jun 2006 02:32:58 +0900 (JST)
Message-ID: <20060630.023258.83835473.yoshfuji@linux-ipv6.org>
References: <20060628.000715.95062023.davem@davemloft.net>
	<adawtazgawi.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, akpm@osdl.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:11788 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751085AbWF2Rb6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 13:31:58 -0400
To: rdreier@cisco.com
In-Reply-To: <adawtazgawi.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <adawtazgawi.fsf@cisco.com> (at Thu, 29 Jun 2006 09:54:37 -0700), Roland Dreier <rdreier@cisco.com> says:

>     David> Roland, there is no way in the world we would have let
>     David> support for RDMA into the kernel tree had we seen and
>     David> reviewed it on netdev.  I've discussed this with Andrew
>     David> Morton, and we'd like you to please revert all of the RDMA
>     David> code from Linus's tree immedialtely.
> 
>     David> Folks are well aware how against RDMA and TOE type schemes
>     David> the Linux networking developers are.  So the fact that none
>     David> of these RDMA changes went up for review on netdev strikes
>     David> me as just a little bit more than suspicious.
> 
> [I'm really on paternity leave, but this was brought to my attention
> and seems important enough to respond to]
> 
> Dave, you're going to have to be more specific.  What do you mean by
> RDMA?  The whole drivers/infiniband infrastructure, which handles RDMA
> over IB, has been upstream for a year and a half, and was in fact
> originally merged by you, so I'm guessing that's not what you mean.

NET_DMA things.

--yoshfuji
