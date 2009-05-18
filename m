From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove needless (now buggy) & from
 dev->dev_addr (part2)
Date: Sun, 17 May 2009 20:25:53 -0700 (PDT)
Message-ID: <20090517.202553.234627593.davem@davemloft.net>
References: <20090514103611.d8dc2bc6.sfr@canb.auug.org.au>
	<20090517.140004.153017718.davem@davemloft.net>
	<20090518103251.86bd3f41.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, sachinp@in.ibm.com,
	yjwei@cn.fujitsu.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57989
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771AbZERDZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 23:25:56 -0400
In-Reply-To: <20090518103251.86bd3f41.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 18 May 2009 10:32:51 +1000

> Though if you had put them into net-current and sent them to Linus (as
> preemptive fixes) there would have been no bisection hole in Linus'
> tree.  Just a minor point.

Indeed, in retrospect that might have been a better approach.

I will keep that in mind for similar future situations, thanks.
