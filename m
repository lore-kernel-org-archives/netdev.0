From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: Re: net 00/05: routing based send-to-self implementation
Date: Fri, 14 Jan 2011 18:02:25 +0300
Message-ID: <20110114150225.GA8815@tugrik.mns.mnsspb.ru>
References: <20091203112550.15100.86217.sendpatchset@x2.localnet> <20110114101832.GA3170@tugrik.mns.mnsspb.ru> <20110114064048.5829220a@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org, Boris Kocherov <bkocherov@gmail.com>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:49826 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757676Ab1ANPBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 10:01:14 -0500
Content-Disposition: inline
In-Reply-To: <20110114064048.5829220a@bike.lwn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 06:40:48AM -0700, Jonathan Corbet wrote:
> On Fri, 14 Jan 2011 13:18:32 +0300
> Kirill Smelkov <kirr@mns.spb.ru> wrote:
> 
> >  ( Jonathan, I though something like this could be useful for LDD4 in
> >    revised snull not needing to play dirty tricks with IP addresses anymore )
> 
> Nice thought, thanks.  I don't know yet whether we'd want to do that or
> just run stuff on a virtual machine for LDD4 - lots of stuff to figure
> out still.

Just FYI: I've started with virtual machines, but figured out it is
(sometimes, maybe my fault) a bit of pain to coherently setup and also
that not all hardware have support for KVM - for example my netbook with
Atom N455, which I use half the time, does not support VT and they've
killed support for KQEMU in QEMU recently...

Anyway, good luck with LDD4!

Thanks,
Kirill
