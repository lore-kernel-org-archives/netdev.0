From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-12-18
Date: Sun, 20 Dec 2009 18:29:10 -0800 (PST)
Message-ID: <20091220.182910.226760127.davem@davemloft.net>
References: <20091218211945.GC2828@tuxdriver.com>
	<20091220.001736.189688434.davem@davemloft.net>
	<20091220133800.GA4700@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091220133800.GA4700-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Sun, 20 Dec 2009 08:38:00 -0500

> On Sun, Dec 20, 2009 at 12:17:36AM -0800, David Miller wrote:
>> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
>> Date: Fri, 18 Dec 2009 16:19:45 -0500
>> 
>> > Please let me know if there are problems!
>> 
>> Your tree is based upon Linus's not net-2.6
>> so when I pulled I got a lot of unrelated
>> commits.
>> 
>> Please fix this, thanks.
> 
> It's based on 2.6.33-rc1.  Are you not going to pull that into net-2.6?

Why in the world should I?  There are no conflicts to resolve
that I know of.

And if there are no conflicts to resolve, pulling in Linus's
tree just makes future pulls into his tree more ugly.

This is pretty standard practice, but in any event you shouldn't ever
care.

You should simply always work against net-2.6, there is no reason to
work against any other tree.

This is a pretty fundamental thing, I don't know why you based against
Linus's tree instead of net-2.6.  Now you have to rebase already :-/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
