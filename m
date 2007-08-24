From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] Add v4mapped address inline
Date: Fri, 24 Aug 2007 19:19:58 +0900 (JST)
Message-ID: <20070824.191958.90290099.yoshfuji@linux-ipv6.org>
References: <46CDB896.8040408@hp.com>
	<20070824.030002.56135604.yoshfuji@linux-ipv6.org>
	<46CDCE8B.6010909@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	yoshfuji@linux-ipv6.org
To: brian.haley@hp.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59222 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972AbXHXKSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 06:18:47 -0400
In-Reply-To: <46CDCE8B.6010909@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <46CDCE8B.6010909@hp.com> (at Thu, 23 Aug 2007 14:14:35 -0400), Brian Haley <brian.haley@hp.com> says:

> YOSHIFUJI Hideaki / ???? wrote:
> > Please put this just after ipv6_addr_any(), not after
> > ipv6_addr_diff().
> 
> Ok, updated patch attached.
> 
> -Brian
> 
> 
> Add v4mapped address inline to avoid calls to ipv6_addr_type().
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
