From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipvs: use pkts for SCTP too
Date: Thu, 02 Sep 2010 10:05:09 -0700 (PDT)
Message-ID: <20100902.100509.39176005.davem@davemloft.net>
References: <Pine.LNX.4.58.1009020242060.14271@u.domain.uli>
	<20100902020331.GS8174@verge.net.au>
	<20100902081913.GC28727@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kaber@trash.net,
	wensong@linux-vs.org, ja@ssi.bg
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752146Ab0IBREx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 13:04:53 -0400
In-Reply-To: <20100902081913.GC28727@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Thu, 2 Sep 2010 17:19:14 +0900

> From: Julian Anastasov <ja@ssi.bg>
> 
> Use correctly the in_pkts packet counter also for SCTP
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied.
