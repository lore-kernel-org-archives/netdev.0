From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'upstream-davem' branch of wireless-2.6
Date: Wed, 18 Jul 2007 15:32:48 -0700 (PDT)
Message-ID: <20070718.153248.82378078.davem@davemloft.net>
References: <20070718021607.GB26907@tuxdriver.com>
	<20070717.201716.112622844.davem@davemloft.net>
	<20070718153449.GA6625@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070718153449.GA6625-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 18 Jul 2007 11:34:49 -0400

> On Tue, Jul 17, 2007 at 08:17:16PM -0700, David Miller wrote:
> > From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> > Date: Tue, 17 Jul 2007 22:16:07 -0400
> > 
> > > A few more for 2.6.23...individual patches available here:
> > > 
> > >   http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem
> > 
> > What about this warning which I reported to you right after the last
> > merge?  Did this get fixed?
> > 
> > net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer types lacks a cast
> > 
> > Please fix that up first, then I'll pull from your tree.
> 
> Fair enough! :-)

As I pointed out to Jiri, you need to spell out the complete type
warning fix, rather than just "unsigned".
