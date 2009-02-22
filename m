From: David Miller <davem@davemloft.net>
Subject: Re: Yet more fixes to etherh.c
Date: Sun, 22 Feb 2009 04:29:52 -0800 (PST)
Message-ID: <20090222.042952.02957933.davem@davemloft.net>
References: <20090222084558.GH16596@n2100.arm.linux.org.uk>
	<20090222.023933.207642182.davem@davemloft.net>
	<20090222114601.GD28025@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754079AbZBVMaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 07:30:10 -0500
In-Reply-To: <20090222114601.GD28025@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sun, 22 Feb 2009 11:46:01 +0000

> So, as far as I can see, I never sent you a patch for to fix the
> eth_set_mac_addr -> eth_mac_addr change.  If you have that in your
> tree, someone else must have sent it to you (maybe Stephen forwarded
> it?)

Nevermind, I see what happened, I got your commit when I merged
upstream into net-next-2.6 to resolve some merge conflicts.

Ok, I'll revert today's patch from my tree and let it propagate via
your's.
