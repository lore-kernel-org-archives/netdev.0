From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Yet more fixes to etherh.c
Date: Sun, 22 Feb 2009 12:34:58 +0000
Message-ID: <20090222123458.GF28025@n2100.arm.linux.org.uk>
References: <20090222084558.GH16596@n2100.arm.linux.org.uk> <20090222.023933.207642182.davem@davemloft.net> <20090222114601.GD28025@n2100.arm.linux.org.uk> <20090222.042952.02957933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:49168 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059AbZBVMfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 07:35:11 -0500
Content-Disposition: inline
In-Reply-To: <20090222.042952.02957933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 22, 2009 at 04:29:52AM -0800, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Sun, 22 Feb 2009 11:46:01 +0000
> 
> > So, as far as I can see, I never sent you a patch for to fix the
> > eth_set_mac_addr -> eth_mac_addr change.  If you have that in your
> > tree, someone else must have sent it to you (maybe Stephen forwarded
> > it?)
> 
> Nevermind, I see what happened, I got your commit when I merged
> upstream into net-next-2.6 to resolve some merge conflicts.
> 
> Ok, I'll revert today's patch from my tree and let it propagate via
> your's.

I don't mind how it gets in, as long as it does.  Since you seem happy
for it to propagate via mine, can I assume you're acking it?
