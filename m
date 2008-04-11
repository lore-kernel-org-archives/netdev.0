From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 22:22:37 +0200
Message-ID: <m3fxtsp2eq.fsf@maximus.localdomain>
References: <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com>
	<20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com>
	<20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org>
	<20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com>
	<20080411164542.GA4066@infradead.org>
	<alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
	<20080411175304.GF11962@parisc-linux.org>
	<alpine.LFD.1.00.0804111146450.3143@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <matthew@wil.cx>,
	Christoph Hellwig <hch@infradead.org>,
	"Kok\, Auke" <auke-jan.h.kok@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak\, John" <john.ronciak@intel.com>,
	"Allan\, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ZSM1387.piap.pl ([195.187.100.11]:52324 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758942AbYDKUWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 16:22:40 -0400
In-Reply-To: <alpine.LFD.1.00.0804111146450.3143@woody.linux-foundation.org> (Linus Torvalds's message of "Fri\, 11 Apr 2008 11\:51\:07 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> Nobody wants to care deeply whether it's a PCI-E or PCI chip. In fact, 
> it's almost impossible to tell. Here, quickly, tell me which one mine is 
> (this is from /sbin/lspci):
>
> 	00:19.0 Ethernet controller: Intel Corporation 82566DM Gigabit Network Connection (rev 02)
>
> and tell me how you knew..

I guess PCIE. You already came across a similar problem.

Have I won something? :-)
-- 
Krzysztof Halasa
