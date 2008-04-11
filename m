From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 09:22:56 -0700
Message-ID: <47FF9060.5040202@intel.com>
References: <47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com> <20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org> <20080411121606.GA25661@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
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
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43660 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758329AbYDKQhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 12:37:33 -0400
In-Reply-To: <20080411121606.GA25661@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> i dont really care _how_ this gets solved - i'm not maintaining this 
> code. What forced me to deal with it was this outright denial of my 
> problem, the ridiculing and NACK-ing of it and general stonewalling.

this is a gross misrepresentation and misunderstanding. You're completely ignoring
the fact that:

(1) I debated whether it was a "regression" - in my opinion design changes that
deliberately break things are hardly worth this incredibly negative stamp

(2) I never NACK'ed your patch. I just withdrew my ack.

(3) You're stonewalling me by pretty much forcing me to completely drop the driver
split and not showing any understanding for the reason behind the split at all.


You don't provide a solution, nor does anyone, and I don't see any solution to
what you want but to completely cancel this driver split.

And I'm _not_ going to do that.


