From: Greg KH <gregkh@suse.de>
Subject: Re: patch "appletalk: move to staging" added to staging tree
Date: Mon, 31 Jan 2011 14:02:40 -0800
Message-ID: <20110131220240.GA32600@suse.de>
References: <12965099622238@site>
 <201101312255.39981.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51341 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754179Ab1AaWEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 17:04:25 -0500
Content-Disposition: inline
In-Reply-To: <201101312255.39981.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 31, 2011 at 10:55:39PM +0100, Arnd Bergmann wrote:
> On Monday 31 January 2011, gregkh@suse.de wrote:
> > 
> > This is a note to let you know that I've just added the patch titled
> > 
> >     appletalk: move to staging
> > 
> > to my staging git tree which can be found at
> >     git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.6.git
> > in the staging-next branch.
> 
> Actually, David Miller objected to this patch for good reasons, please
> revert it. One of the other patches removes the BKL in appletalk, so
> we should find a way to keep it.

Oops, sorry about that, I'll go revert it.

greg k-h
