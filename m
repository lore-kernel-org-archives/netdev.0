From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Fri, 6 Jul 2007 14:47:11 +0200
Message-ID: <20070706124711.GA3453@ff.dom.local>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org> <1183642800.3789.11.camel@ranko-fc2.spidernet.net> <20070705142135.GG4759@ff.dom.local> <1183646029.4069.11.camel@ranko-fc2.spidernet.net> <1183651165.4069.26.camel@ranko-fc2.spidernet.net> <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local> <20070706064523.GA2144@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, kaber@trash.net, netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:39119 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760206AbXGFMil (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 08:38:41 -0400
Content-Disposition: inline
In-Reply-To: <20070706064523.GA2144@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 06, 2007 at 08:45:23AM +0200, Jarek Poplawski wrote:
> On Fri, Jul 06, 2007 at 09:08:43AM +0300, Ranko Zivojnovic wrote:
...
> > In order to get that parameter out of the way - I will make the same
> > test on a real machine.

BTW, maybe it would be better to try with something more stable than -mm.
There is also one bug invoked by sysreq, but I hope you've started to use
sysreq only after the lockup begun.

Jarek P.
