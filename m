From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression] e1000e broke e1000
Date: Tue, 8 Apr 2008 22:35:07 +0200
Message-ID: <20080408203507.GB28952@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <36D9DB17C6DE9E40B059440DB8D95F5204E2A55C@orsmsx418.amr.corp.intel.com> <20080408195949.GB28148@elte.hu> <20080408200417.GI11962@parisc-linux.org> <47FBD1AD.1080700@isomerica.net> <20080408202003.GJ11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Noe <dpn@isomerica.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:45586 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017AbYDHUfk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 16:35:40 -0400
Content-Disposition: inline
In-Reply-To: <20080408202003.GJ11962@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Matthew Wilcox <matthew@wil.cx> wrote:

> On Tue, Apr 08, 2008 at 04:12:29PM -0400, Dan Noe wrote:
> > It would be nice if lspci could display what driver had claimed a 
> > particular device
> 
> You need to upgrade to a more recent version of lspci -- it already 
> does this ;-)

yes, but it does not (yet) display the negative condition and the reason 
for that. (if the kernel knows the reason - and in most cases it knows 
it)

	Ingo
