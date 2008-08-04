From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2008-08-04
Date: Mon, 4 Aug 2008 17:54:39 -0400
Message-ID: <20080804215439.GA9658@tuxdriver.com>
References: <20080804193753.GA30345@tuxdriver.com> <1217882288.7819.19.camel@californication> <20080804204558.GA5866@tuxdriver.com> <1217886123.7819.23.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4945 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764647AbYHDWDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 18:03:04 -0400
Content-Disposition: inline
In-Reply-To: <1217886123.7819.23.camel@californication>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 11:42:03PM +0200, Marcel Holtmann wrote:

> > > > Luis R. Rodriguez (4):
> > > >       list.h: Add list_splice_tail() and list_splice_tail_init()
> > > >       list.h: add list_cut_position()
> > > 
> > > have these two changes got reviewed on LKML? I don't see any ACKs for it
> > > in the commit message.
> > 
> > Hmmm...no.  I thought the original patches had been copied to
> > linux-kernel, but it looks like that is not the case.
> > 
> > The original patches are archived here:
> > 
> > 	http://marc.info/?l=linux-wireless&m=121783421908441&w=2
> > 
> > 	http://marc.info/?l=linux-wireless&m=121783422008445&w=2
> > 
> > What problems do you see with them?
> 
> I don't see a problem with these patches, but they should at least be
> reviewed on LKML once. Changes to core kernel infrastructure should not
> be merged silently via subsystem trees without any kind of ACKs.

Yes, fine.  That wasn't my intent. :-)  The patches were originally
posted about two weeks ago, too bad that didn't actually go to
linux-kernel. :-(

John
-- 
John W. Linville
linville@tuxdriver.com
