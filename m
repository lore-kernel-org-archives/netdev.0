From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2008-08-29
Date: Sat, 30 Aug 2008 08:58:33 -0400
Message-ID: <20080830125833.GC11718@tuxdriver.com>
References: <20080829205414.GB11718@tuxdriver.com> <20080829.140303.71048853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080829.140303.71048853.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 29, 2008 at 02:03:03PM -0700, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Fri, 29 Aug 2008 16:54:14 -0400
> 
> > Here is this week's supply of stuff for -next -- mostly cleanups and
> > other driver updates.  Please let me know if there are problems!
>  ...
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master
> 
> I'm pulling this, thanks John.
> 
> I hope to get a chance tonight to deal with that net-2.6 vs. net-next-2.6
> wireless conflict by doing a merge.  It had to do with that IBSS message
> your ifdef'd out in net-2.6

Ah, yes...it looks trivial to fix, but the trivial fix won't build!

I have it fixed here:

	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git merged-test

And the fixed file is the same as what is in wireless-testing.

Hth!

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
