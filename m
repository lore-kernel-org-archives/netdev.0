From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2010-07-23
Date: Fri, 23 Jul 2010 14:03:20 -0700 (PDT)
Message-ID: <20100723.140320.116366019.davem@davemloft.net>
References: <20100723204029.GD2426@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100723204029.GD2426-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 23 Jul 2010 16:40:29 -0400

> Yet another batch intended for 2.6.36...  Mostly the usual random lot
> of stuff, mostly driver updates.  This batch also includes a flurry
> of Sparse-inspired patches from me -- it is hard to resist once the
> "bug" bites!  As usual, all of these have been cooking in linux-next
> for at least several days.
> 
> Please let me know if there are problems!

Auto-merging drivers/net/wireless/iwlwifi/iwl-commands.h
CONFLICT (content): Merge conflict in drivers/net/wireless/iwlwifi/iwl-commands.h

I don't even have to look at the file to know that it's
another one of those __packed things.

I'll fix it up again, but I know you can sense how tiring
this has become for me.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
