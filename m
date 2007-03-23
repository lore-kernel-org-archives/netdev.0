From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 00/11]: pkt_sched.h cleanup + misc changes
Date: Fri, 23 Mar 2007 11:30:19 -0700 (PDT)
Message-ID: <20070323.113019.97293991.davem@davemloft.net>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753300AbXCWSaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 14:30:19 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 23 Mar 2007 14:35:38 +0100 (MET)

> These patches fix an off-by-one in netem, clean up pkt_sched.h by removing
> most of the now unnecessary PSCHED time macros and turning the two remaining
> ones into inline functions, consolidate some common filter destruction code
> and move the TCQ_F_THROTTLED optimization from netem to qdisc_restart.
> 
> Please apply, thanks.

Patches 1-10 applied.
