From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RDMA will be reverted
Date: Thu, 29 Jun 2006 10:35:56 -0700
Message-ID: <adasllng8zn.fsf@cisco.com>
References: <20060628.000715.95062023.davem@davemloft.net>
	<adawtazgawi.fsf@cisco.com>
	<20060630.023258.83835473.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:25909 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1751031AbWF2RgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 13:36:07 -0400
To: YOSHIFUJI Hideaki /
	 =?us-ascii?Q?=3D=3Fiso-2022-jp=3FB=3FGyRCNUhGIzFRT?=
	 =?us-ascii?Q?EAbKEI=3D=3F=3D?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20060630.023258.83835473.yoshfuji@linux-ipv6.org> (YOSHIFUJI Hideaki's message of "Fri, 30 Jun 2006 02:32:58 +0900 (JST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > Dave, you're going to have to be more specific.  What do you mean by
 > > RDMA?  The whole drivers/infiniband infrastructure, which handles RDMA
 > > over IB, has been upstream for a year and a half, and was in fact
 > > originally merged by you, so I'm guessing that's not what you mean.
 > 
 > NET_DMA things.

But NET_DMA seems to be for the new DMA engine support (I/OAT really I
guess?).  I had nothing to do with merging any of that, and as far as
I can tell, Dave signed off on all of those changes, so I don't think
that's what he's complaining about either.

 - R.
