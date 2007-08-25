From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] Add v4mapped address inline
Date: Fri, 24 Aug 2007 23:16:20 -0700 (PDT)
Message-ID: <20070824.231620.27453147.davem@davemloft.net>
References: <46CDB896.8040408@hp.com>
	<20070824.030002.56135604.yoshfuji@linux-ipv6.org>
	<46CDCE8B.6010909@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38661
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752937AbXHYGQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:16:22 -0400
In-Reply-To: <46CDCE8B.6010909@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Thu, 23 Aug 2007 14:14:35 -0400

> YOSHIFUJI Hideaki / ???? wrote:
> > Please put this just after ipv6_addr_any(), not after
> > ipv6_addr_diff().
> 
> Ok, updated patch attached.
> 
> Add v4mapped address inline to avoid calls to ipv6_addr_type().
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied, thanks Brian.
