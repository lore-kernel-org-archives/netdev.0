From: Martin Mares <mj@ucw.cz>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 19:10:26 +0200
Message-ID: <mj+md-20080411.170932.9941.albireo@ucw.cz>
References: <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com> <20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org> <20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>,
	Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jabberwock.ucw.cz ([89.250.246.4]:37808 "EHLO jabberwock.ucw.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760634AbYDKRMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 13:12:43 -0400
Received: from albireo.ucw.cz (albireo.ucw.cz [89.239.2.32])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "albireo.ucw.cz", Issuer "ucw.cz" (verified OK))
	by jabberwock.ucw.cz (Postfix) with ESMTP id 6E4FD342A2
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 19:12:40 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <47FF9060.5040202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> You don't provide a solution, nor does anyone, and I don't see any solution to
> what you want but to completely cancel this driver split.

Maybe you could rename both configuration switches, so that you bring it to
the attention of everybody who does make oldconfig?

				Have a nice fortnight
-- 
Martin `MJ' Mares                          <mj@ucw.cz>   http://mj.ucw.cz/
Faculty of Math and Physics, Charles University, Prague, Czech Rep., Earth
main(){char *s="main(){char *s=%c%s%c;printf(s,34,s,34);}";printf(s,34,s,34);}
