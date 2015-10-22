From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: mac80211-next 2015-10-21
Date: Thu, 22 Oct 2015 07:29:19 -0700 (PDT)
Message-ID: <20151022.072919.1996665963889101709.davem@davemloft.net>
References: <1445440026.4558.62.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445440026.4558.62.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 21 Oct 2015 17:07:06 +0200

> Here's another, likely final, pull request for -next. I finally caved
> in and cleaned up the regulatory code a bit, which is the bulk of the
> changes.
> 
> There's a new Kconfig which allows turning off CRDA, but it's hidden
> behind having the internal regdb enabled, which in turn is hidden
> behind EXPERT, so hopefully you won't even see that :) (although I am
> hoping to get rid of the internal regdb sooner rather than later)
> 
> Let me know if you see any problems.

Pulled, thanks a lot Johannes.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
