From: Pavel Machek <pavel@ucw.cz>
Subject: Re: wireless (was Re: 2.6.18 -mm merge plans)
Date: Sat, 10 Jun 2006 06:58:50 +0000
Message-ID: <20060610065850.GA4346@ucw.cz>
References: <20060604135011.decdc7c9.akpm@osdl.org> <20060605010636.GB17361@havoc.gtf.org> <20060604181515.8faa8fcf.akpm@osdl.org> <20060605083321.GA15690@rhlx01.fht-esslingen.de> <1149497109.3111.28.camel@laptopd505.fenrus.org> <1149503215.30554.6.camel@localhost.localdomain> <1149503730.3111.46.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andreas Mohr <andi@rhlx01.fht-esslingen.de>,
	Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net,
	acx100-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:48133 "EHLO
	spitz.ucw.cz") by vger.kernel.org with ESMTP id S1030322AbWFJHHz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 03:07:55 -0400
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1149503730.3111.46.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > >  It's just that a cleanroom approach is a sure way to prove
> > > you didn't copy. That's all.
> > 
> > Which is an extremely important detail especially if you have been
> > reverse engineering another driver for the same or similar OS where it
> > is likely that people will retain knowledge and copy rather than
> > re-implement th?ngs.
> 
> oh don't get me wrong, it's important to not copy from the original.
> (even if that original did copy from linux ;)

Well, if original did copy from linux, it surely is GPLed and case
closed, no? Being sued from vendor not respecting the GPL would
probably only do harm to them.

Like US courts are crazy, but hopefully not _that_ crazy.
							Pavel
-- 
Thanks for all the (sleeping) penguins.
