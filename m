From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-03-04
Date: Tue, 04 Mar 2008 13:40:03 -0800 (PST)
Message-ID: <20080304.134003.223058560.davem@davemloft.net>
References: <20080304212953.GB3158@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080304212953.GB3158-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 4 Mar 2008 16:29:53 -0500

> Here is today's round of fixes for the 2.6.25 tree.  These are mostly
> simple fixes, even one-liners.  The rc80211-pid patch is, of course, an
> exception...

Please don't just clone Linus's tree, pull net-2.6, and then stuff
things on top of that and ask me to pull.  I end up being forced to
end up with a merge of Linus's current tree as a result, and that's
not how this is supposed to work.

I keep net-2.6 stable for a reason.  Jeff did what you're doing right
now the other week and now you're doing it too.

There is zero point in my keeping net-2.6 clean and not rebasing it
constantly if people are going to use it like this.

You should just have a clone of net-2.6 sitting around as your
wireless fixes tree, and you simply add wireless patches and ask me to
pull whenever it is appropriate.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
