From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH][netdrvr] lib8390: comment on locking by Alan Cox Re:
 2.6.20->2.6.21 - networking dies after random time
Date: Thu, 26 Jul 2007 13:47:14 +0100
Message-ID: <20070726134714.31882b7e@the-village.bc.nu>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com>
	<20070629150759.GC2771@ff.dom.local>
	<4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
	<20070724080534.GC18740@elte.hu>
	<20070724094202.GA11610@elte.hu>
	<alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
	<20070724200431.GA22190@elte.hu>
	<1185322771.4175.102.camel@chaos>
	<20070725135718.GB1843@ff.dom.local>
	<20070725154656.54fd6f13@the-village.bc.nu>
	<20070726124401.GC3423@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Marcin ??lusarz <marcin.slusarz@gmail.com>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paul Gortmaker <p_gortmaker@yahoo.com>,
	Jeff Garzik <jeff@garzik.org>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:53840 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754864AbXGZMlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 08:41:37 -0400
In-Reply-To: <20070726124401.GC3423@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Jul 2007 14:44:01 +0200
Jarek Poplawski <jarkao2@o2.pl> wrote:

> Hi,
> 
> Very below is my patch proposal with a comment, which in my opinion
> is precious enough to save it for future help in reading and
> understanding the code.
> 
> I hope Alan will not blame me I've not asked for his permission before
> sending, and he would ack this patch as it is or at least most of this.

Fine by me

