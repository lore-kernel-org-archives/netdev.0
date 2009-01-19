From: "stanley.miao" <stanley.miao@windriver.com>
Subject: Re: [PATCH REPOST 0/5] convert arm platforms to smsc911x
Date: Mon, 19 Jan 2009 16:04:34 +0800
Message-ID: <1232352274.23192.25.camel@localhost>
References: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com>
	 <20090118.215321.59760406.davem@davemloft.net>
Reply-To: stanley.miao@windriver.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, ian.saturley@smsc.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62840 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754308AbZASH4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 02:56:15 -0500
In-Reply-To: <20090118.215321.59760406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-01-18 at 21:53 -0800, David Miller wrote:
> From: Steve Glendinning <steve.glendinning@smsc.com>
> Date: Thu, 15 Jan 2009 09:07:57 +0000
> 
> > This patchset, intended for 2.6.30, converts all in-tree arm platforms 
> > from smc911x to the actively maintained smsc911x driver.
> > 
> > I don't have any of these platforms available to me, so I've only been 
> > able to compile-test the changes.
> > 
> > David Miller is planning to take the smsc911x patches via net-2.6, but 
> > I've included them here to make testing easier as the other patches in 
> > the set depend on them.
> > 
> > This patchset supercedes previous irq_flags patches from me and Stanley 
> > Miao.
> 
> I've applied patches 1 and 2, the smsc911x driver changes.
> 
> I can pull the platform changes into net-next-2.6 as well
> if people don't think there will enough conflicts to cause
> problems.

I think  the platform data had better stay in arm tree.

Stanley.
