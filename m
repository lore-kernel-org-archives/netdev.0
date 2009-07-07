From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [patch] ipv6: correct return on ipv6_rcv() packet drop
Date: Wed, 8 Jul 2009 06:34:13 +0930
Message-ID: <20090708063413.fe18dc6f.lk-netdev@lk-netdev.nosense.org>
References: <20090707065624.ee55809e.lk-netdev@lk-netdev.nosense.org>
	<20090706.180945.113737445.davem@davemloft.net>
	<20090707185015.391c893f.lk-netdev@lk-netdev.nosense.org>
	<20090707.085219.101591166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:48844 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755841AbZGGVE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 17:04:27 -0400
In-Reply-To: <20090707.085219.101591166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Jul 2009 08:52:19 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
> Date: Tue, 7 Jul 2009 18:50:15 +0930
> 
> > Today I came across this earlier partial version of what I
> > independently identified and submitted, so I shouldn't get full credit
> > for it:
> > 
> > http://lkml.indiana.edu/hypermail/linux/kernel/0804.1/2393.html
> 
> I already pushed your change out to my public tree so we're
> past the point of being able to modify the commit message.
> 
> We'll just try to be more careful next time.

Is there an easier way to avoid this, other than a google search? I
happened to discover it by doing a google search when I was at work, to
see how my patch was going. I suppose possibly not.
