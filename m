From: David Miller <davem@davemloft.net>
Subject: Re: net-26.24 broken with XFRM off
Date: Thu, 06 Sep 2007 02:50:46 -0700 (PDT)
Message-ID: <20070906.025046.74721747.davem@davemloft.net>
References: <46DFAB7F.7060406@chelsio.com>
	<20070906101326.34a81abb.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, takamiya@po.ntts.co.jp
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:47582
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750967AbXIFJvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 05:51:24 -0400
In-Reply-To: <20070906101326.34a81abb.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 6 Sep 2007 10:13:26 +0200

> I believe this problem is known.
> 
> Please check http://marc.info/?l=linux-netdev&m=118881627028135&w=2 

I'll toss that fix into the tree, thanks.
