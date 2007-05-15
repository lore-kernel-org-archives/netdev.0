From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] netdev: lockdep classes in register_netdevice Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Tue, 15 May 2007 12:05:12 +0200
Message-ID: <20070515100512.GA3050@ff.dom.local>
References: <20070511.140309.59656886.davem@davemloft.net> <20070511141225.cf7a6909.akpm@linux-foundation.org> <20070514060700.GA1000@ff.dom.local> <20070513.233937.99203647.davem@davemloft.net> <20070515053101.GA990@ff.dom.local> <025c01c796cd$fe9ccee0$0202fea9@Jura>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	jeff@garzik.org, netdev@vger.kernel.org, paulus@samba.org
To: "Yuriy N\. Shkandybin" <jura@netams.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:51495 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759122AbXEOJ6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 05:58:39 -0400
Content-Disposition: inline
In-Reply-To: <025c01c796cd$fe9ccee0$0202fea9@Jura>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 15, 2007 at 12:49:47PM +0400, Yuriy N. Shkandybin wrote:
> I've patched 2.6.22-rc1 and there was no warnings from lock debugger.
> 
> Jura

Many thanks, Jura!

It seems reality is sometimes merciful...

On the other hand I wonder, how all this could stay so long:
a configuration similar to yours should be quite common. It
looks, some people probably don't care, and here your help
is even more precious!

Best regards,
Jarek P.
