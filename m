From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Wed, 09 Apr 2008 15:50:14 -0400
Message-ID: <47FD1DF6.2000007@garzik.org>
References: <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew@wil.cx>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
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
Received: from srv5.dvmed.net ([207.36.208.214]:38897 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754059AbYDITu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 15:50:29 -0400
In-Reply-To: <20080409193850.GA11763@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Jeff Garzik <jeff@garzik.org> wrote:
> 
>>> We've got three thousand Kconfig options - it is clearly not 
>>> realistic for users to keep such details in mind to avoid pitfalls.
>> Agreed -- hence the multiple announcements, including in this thread, 
>> to put said details into mind.
> 
> which part of "it took a kernel developer more than an hour to figure 
> out why his laptop had a dead network interface" did you not understand? 
> Whatever you did, it was not apparent to me. I dont follow every tiny 
> detail of the e1000 driver family, nor do 99%+ [*] of our users.

You do follow LKML, where multiple announcements have and are being posted.

	Jeff



