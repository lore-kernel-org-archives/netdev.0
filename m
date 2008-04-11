From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 13:38:10 -0600
Message-ID: <20080411193810.GI11962@parisc-linux.org>
References: <20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org> <20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com> <20080411164542.GA4066@infradead.org> <alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org> <20080411175304.GF11962@parisc-linux.org> <alpine.LFD.1.00.0804111146450.3143@woody.linux-foundation.org> <20080411190128.GG11962@parisc-linux.org> <20080411192519.GA8474@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:44371 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757195AbYDKTiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 15:38:12 -0400
Content-Disposition: inline
In-Reply-To: <20080411192519.GA8474@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 09:25:19PM +0200, Willy Tarreau wrote:
> Here if people don't know, they will reply "no" too.

I learned not to do that ... back in 2.3, iirc, when the console
became selectable ;-)

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
