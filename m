From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: RDMA will be reverted
Date: Fri, 30 Jun 2006 02:40:51 +0900 (JST)
Message-ID: <20060630.024051.59274107.yoshfuji@linux-ipv6.org>
References: <adawtazgawi.fsf@cisco.com>
	<20060630.023258.83835473.yoshfuji@linux-ipv6.org>
	<adasllng8zn.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, akpm@osdl.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:14092 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751026AbWF2Rjw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 13:39:52 -0400
To: rdreier@cisco.com
In-Reply-To: <adasllng8zn.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <adasllng8zn.fsf@cisco.com> (at Thu, 29 Jun 2006 10:35:56 -0700), Roland Dreier <rdreier@cisco.com> says:

>  > > Dave, you're going to have to be more specific.  What do you mean by
>  > > RDMA?  The whole drivers/infiniband infrastructure, which handles RDMA
>  > > over IB, has been upstream for a year and a half, and was in fact
>  > > originally merged by you, so I'm guessing that's not what you mean.
>  > 
>  > NET_DMA things.
> 
> But NET_DMA seems to be for the new DMA engine support (I/OAT really I
> guess?).  I had nothing to do with merging any of that, and as far as
> I can tell, Dave signed off on all of those changes, so I don't think
> that's what he's complaining about either.

Oops, sorry, you're right...

--yoshfuji
