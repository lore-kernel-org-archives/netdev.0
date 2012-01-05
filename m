From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2012-01-05
Date: Thu, 05 Jan 2012 12:30:39 -0500 (EST)
Message-ID: <20120105.123039.977245333906219511.davem@davemloft.net>
References: <20120105160938.GC10666@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120105160938.GC10666-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 5 Jan 2012 11:09:38 -0500

> Here is the last wireless "feature" pull request intended for 3.3.
> Mostly minutia, but highlights include an NFC spec update and some
> relicensing of regulatory code under the ISC license.
> 
> After consulation with Kalle, I have reverted the ath6kl USB bits that
> were causing build problems.
> 
> Please let me know if there are problems!
> 
> John
> 
> P.S. Sorry about the "ssh://" URL -- git.kernel.org seems a bit slow
> about syncing today...

That ssh URL would only work for you, since I don't have permission to get
at your trees even just to pull.

I pulled from the equivalent git:// URL, the top commit was the ath6kl
USB revert.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
