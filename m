From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-05-28
Date: Wed, 28 May 2008 20:35:27 -0400
Message-ID: <20080529003527.GC22536@tuxdriver.com>
References: <20080528213831.GA3133@tuxdriver.com> <1212012670.21624.48.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1212012670.21624.48.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 29, 2008 at 12:11:10AM +0200, Johannes Berg wrote:
> On Wed, 2008-05-28 at 17:38 -0400, John W. Linville wrote:
> > David,
> > 
> > Another round of fixes for 2.6.26 follows...
> > 
> > Please let me know if there are problems!
> 
> What about
> 
> [PATCH] b43legacy: fix build errors when DMA or PIO are not selected

That claims to correct a problem created by "mac80211: move TX info
into skb->cb", which is not in the 2.6.26 stream.  I will apply it
to wireless-next-2.6.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
