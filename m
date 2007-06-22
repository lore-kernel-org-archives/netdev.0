From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: 22 Jun 2007 14:22:33 +0200
Message-ID: <ygfk5tw41rq.fsf@janus.isnogud.escape.de>
References: <20070622034452.28886.0@janus.isnogud.escape.de>
	<20070622034703.28886.5@janus.isnogud.escape.de>
	<467BAC48.1070700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:49127 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507AbXFVMaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 08:30:39 -0400
In-Reply-To: <467BAC48.1070700@trash.net>; from Patrick McHardy on Fri, 22 Jun 2007 13:02:32 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Is there a reason why you're still doing the "allocate n devices
> on init" thing instead of using the rtnl_link API?

Sorry, it's simply a matter of time.  We have been extremely busy with
other projects and two presentations (mgmt, customers, and press) the
last two weeks and have worked on the other changes this week.  I'm
sorry I haven't yet been able to look at your rtnl_link code close
enough, but it's definitely on my todo list.  Starting on Sunday I'll
be on a business trip to .jp for a week, and I hope I get to it in
that week, otherwise on return.

urs
