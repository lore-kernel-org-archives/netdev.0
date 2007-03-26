From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Remove dead net/sched/Makefile entry for
 sch_hpfq.o.
Date: Mon, 26 Mar 2007 16:20:52 -0700 (PDT)
Message-ID: <20070326.162052.41635110.davem@davemloft.net>
References: <Pine.LNX.4.64.0703261907320.24253@CPE00045a9c397f-CM001225dbafb6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rpjday@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36308
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933686AbXCZXUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 19:20:54 -0400
In-Reply-To: <Pine.LNX.4.64.0703261907320.24253@CPE00045a9c397f-CM001225dbafb6>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Robert P. J. Day" <rpjday@mindspring.com>
Date: Mon, 26 Mar 2007 19:10:03 -0400 (EDT)

> 
> Remove the worthless net/sched/Makefile entry for the non-existent
> source file sch_hpfq.c.
> 
> Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

Applied, thanks Robert.

I wonder how cruft like this is able to live for so long :-)
