From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2010-03-31
Date: Wed, 31 Mar 2010 19:33:48 -0700 (PDT)
Message-ID: <20100331.193348.196563619.davem@davemloft.net>
References: <20100331144649.GC3024@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtJ0xCFg78z1Mw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100331144649.GC3024-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 31 Mar 2010 10:46:49 -0400

> Here is a batch of fixes intended for 2.6.34.  Included are a few
> device IDs, along with several almost-one-liners to fix a variety of
> issues, including a NULL deref, a potential overflow, a misues of the
> USB API, a regulatory error for iwlwifi, a race condition in mac80211,
> and some other more minor fixes.
> 
> I saw your note about only "eats someones disk" bugs.  I'm not
> sure all of these meet that test, but I hope you will take them.
> I've been sitting on them a while and letting them cook in linux-next,
> mostly to test one particular patch (which I backed-out yesterday).
> I promise I'll tighten-up after this batch! :-)

Ok, pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
