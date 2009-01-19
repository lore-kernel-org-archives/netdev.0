From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST 0/5] convert arm platforms to smsc911x
Date: Sun, 18 Jan 2009 21:53:21 -0800 (PST)
Message-ID: <20090118.215321.59760406.davem@davemloft.net>
References: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, stanley.miao@windriver.com,
	ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752566AbZASFxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:53:20 -0500
In-Reply-To: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu, 15 Jan 2009 09:07:57 +0000

> This patchset, intended for 2.6.30, converts all in-tree arm platforms 
> from smc911x to the actively maintained smsc911x driver.
> 
> I don't have any of these platforms available to me, so I've only been 
> able to compile-test the changes.
> 
> David Miller is planning to take the smsc911x patches via net-2.6, but 
> I've included them here to make testing easier as the other patches in 
> the set depend on them.
> 
> This patchset supercedes previous irq_flags patches from me and Stanley 
> Miao.

I've applied patches 1 and 2, the smsc911x driver changes.

I can pull the platform changes into net-next-2.6 as well
if people don't think there will enough conflicts to cause
problems.
