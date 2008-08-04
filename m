From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] netdev: debugging option
Date: Mon, 4 Aug 2008 15:34:44 -0700
Message-ID: <20080804153444.51f57276@extreme>
References: <20080719230424.190957a3@extreme>
	<20080720.000509.20260185.davem@davemloft.net>
	<20080804093742.395d271e@extreme>
	<20080804.143128.47731600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:34233 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbYHDWeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 18:34:46 -0400
In-Reply-To: <20080804.143128.47731600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 Aug 2008 14:31:28 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 4 Aug 2008 09:37:42 -0700
> 
> > On Sun, 20 Jul 2008 00:05:09 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Stephen Hemminger <shemminger@vyatta.com>
> > > Date: Sat, 19 Jul 2008 23:04:24 -0700
> > > 
> > > So we really need to add some kind of run time enable and also a
> > > filter of some sort, even if it's just on device.
> > 
> > The sysctl in the patch is default off, so unless it is turned on,
> > the log is quiet
> 
> I get a feeling you think I can just apply your patch now.
> 
> You can't respond to my gripes more than a week later and expect
> the patch to still be in my inbox ready to apply.  I delete the
> patch from my mailbox as soon as I have major issues with it.
> 

Okay, I prioritize my mail replies, and this was on the tickler file of
(things to get back to when the smoke clears).  Just didn't want to let
it die.
