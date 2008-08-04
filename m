From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-04
Date: Mon, 04 Aug 2008 14:58:55 -0700 (PDT)
Message-ID: <20080804.145855.230579810.davem@davemloft.net>
References: <1217882288.7819.19.camel@californication>
	<20080804204558.GA5866@tuxdriver.com>
	<1217886123.7819.23.camel@californication>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1217886123.7819.23.camel@californication>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Date: Mon, 04 Aug 2008 23:42:03 +0200

> Hi John,
> 
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

Right.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
