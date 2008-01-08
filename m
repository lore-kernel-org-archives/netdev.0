From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Tue, 8 Jan 2008 23:56:27 +0100
Message-ID: <200801082356.28258.rjw@sisk.pl>
References: <477FF149.4070609@linux.intel.com> <4783C95C.7050303@linux.intel.com> <alpine.LFD.1.00.0801081126200.3148@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:43841 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753295AbYAHWyD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 17:54:03 -0500
In-Reply-To: <alpine.LFD.1.00.0801081126200.3148@woody.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, 8 of January 2008, Linus Torvalds wrote:
> 
> On Tue, 8 Jan 2008, Arjan van de Ven wrote:
> > 
> > ok done; I had to fizzle a bit because some things aren't *exactly* a 
> > BUG() statement but I track them anyway (things like the "sleeping in 
> > invalid context" check), so I had to somewhat arbitrarily assign 
> > categories for those. I might fine tune these over time some; if you or 
> > someone else sees problems with categorization please let me know
> 
> Looking good. I wonder if we could also have some way to cross-ref these 
> things with the regression list (notably try to get pointers to them in 
> the regression list). 

I'm thinking about that, but haven't invented any automated solution yet.
I only can manually add references to kerneloops.org, for now.

Greetings,
Rafael
