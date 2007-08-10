From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch (testing)] Re: 2.6.20->2.6.21 - networking dies after
	random time
Date: Fri, 10 Aug 2007 10:48:41 +0200
Message-ID: <20070810084841.GA11086@elte.hu>
References: <JMJTMH$F1699B57C9B0E170ED337488612E649B@xandmail.com> <20070810083720.GE1764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	"marcin.slusarz" <marcin.slusarz@gmail.com>,
	tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:34431 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756880AbXHJIsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 04:48:53 -0400
Content-Disposition: inline
In-Reply-To: <20070810083720.GE1764@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jarek Poplawski <jarkao2@o2.pl> wrote:

> On Fri, Aug 10, 2007 at 10:15:53AM +0200, Jean-Baptiste Vignaud wrote:
> ...
> > I was still testing on -rc2:
> > Subject: [patch] genirq: temporary fix for level-triggered IRQ resend
> > Date: Wed, 8 Aug 2007 13:00:37 +0200
> > 
> > For me after 1day 20hours, the network is still up, with more than 
> > 1To of network traffic. HZ was 1000, i restart with HZ=100.
> 
> For me it's enough too but Thomas seems to doubt.

seem to doubt what? That rc2 fixes the symptom? That is a sure thing, 
and we never doubted that. I think you might have misunderstood what 
Thomas said and meant, so please just state your opinion unambiguously 
so that we can fix any mis-communication :)

	Ingo
