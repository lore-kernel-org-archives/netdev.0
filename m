From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2010-07-23
Date: Fri, 23 Jul 2010 17:39:31 -0400
Message-ID: <20100723213931.GF2426@tuxdriver.com>
References: <20100723204029.GD2426@tuxdriver.com>
 <20100723.140320.116366019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100723.140320.116366019.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 02:03:20PM -0700, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Fri, 23 Jul 2010 16:40:29 -0400
> 
> > Yet another batch intended for 2.6.36...  Mostly the usual random lot
> > of stuff, mostly driver updates.  This batch also includes a flurry
> > of Sparse-inspired patches from me -- it is hard to resist once the
> > "bug" bites!  As usual, all of these have been cooking in linux-next
> > for at least several days.
> > 
> > Please let me know if there are problems!
> 
> Auto-merging drivers/net/wireless/iwlwifi/iwl-commands.h
> CONFLICT (content): Merge conflict in drivers/net/wireless/iwlwifi/iwl-commands.h
> 
> I don't even have to look at the file to know that it's
> another one of those __packed things.
> 
> I'll fix it up again, but I know you can sense how tiring
> this has become for me.

I'm sorry, Dave!  I should have done a for-davem branch.  FWIW,
I intended to do a test merge but it must have slipped my fragile
mind. :-(

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
