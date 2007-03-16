From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NET_SCHED 00/10]: ktime clocksource + hrtimer
Date: Fri, 16 Mar 2007 13:41:24 +0100
Message-ID: <20070316124124.GK521@postel.suug.ch>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain> <20070316.023510.41635847.davem@davemloft.net> <45FA6682.10303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org, shemminger@linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46258 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932744AbXCPMlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 08:41:05 -0400
Content-Disposition: inline
In-Reply-To: <45FA6682.10303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2007-03-16 10:42
> David Miller wrote:
> > It would be nice to figure out why CBQ isn't working for
> > you, I know at least some folks have used it successfully
> > at some point.
> 
> Probably my own incompetence, I'll see if I can find some
> scripts that are known to work.

I'll complain if it stops working, I'm still using CBQ to
keep rsync and other bulk flows from interfering with ssh.
HTB just doesn't have the same homy touch :-)
