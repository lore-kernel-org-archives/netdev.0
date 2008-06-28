From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] remove CONFIG_NET_SCH_RR
Date: Fri, 27 Jun 2008 19:54:17 -0700 (PDT)
Message-ID: <20080627.195417.91418574.davem@davemloft.net>
References: <20080623174702.GD4756@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, rpjday@crashcourse.ca
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39403
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751660AbYF1CyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 22:54:17 -0400
In-Reply-To: <20080623174702.GD4756@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 23 Jun 2008 20:47:02 +0300

> Commit d62733c8e437fdb58325617c4b3331769ba82d70
> ([SCHED]: Qdisc changes and sch_rr added for multiqueue)
> added a NET_SCH_RR option that was unused since the code
> went unconditionally into sch_prio.
> 
> Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks Adrian.
