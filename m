From: David Miller <davem@davemloft.net>
Subject: Re: -next Mar 22: s390 build failure (drivers/s390/net/qeth_l3)
Date: Mon, 22 Mar 2010 10:00:05 -0700 (PDT)
Message-ID: <20100322.100005.84370671.davem@davemloft.net>
References: <20100322171937.d753bdba.sfr@canb.auug.org.au>
	<4BA73423.6080101@in.ibm.com>
	<20100322130025.GA8558@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sachinp@in.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49004
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754753Ab0CVQ7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 12:59:42 -0400
In-Reply-To: <20100322130025.GA8558@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Blaschka <frank.blaschka@de.ibm.com>
Date: Mon, 22 Mar 2010 14:00:25 +0100

> [PATCH] qeth: l3 fix build error in ipv6 addr list handling
> 
> From: Frank Blaschka <frank.blaschka@de.ibm.com>
> 
> Adapt qeth l3 to:
> commit c2e21293c054817c42eb5fa9c613d2ad51954136
> (ipv6: convert addrconf list to hlist)
> converted lst_next member of inet6_ifaddr struct to a hlist.
> 
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied, thanks for fixing this Frank.
