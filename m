From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 0/4] nl80211 cleanups
Date: Mon, 04 Oct 2010 21:33:07 +0200
Message-ID: <1286220787.3620.58.camel@jlt3.sipsolutions.net>
References: <20101004191402.183055479@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101004191402.183055479-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-10-04 at 21:14 +0200, Johannes Berg wrote:
> This patchset adds some new hooks to generic
> netlink and then goes on to use them to really
> optimise a lot of locking code in nl80211.
> 
> It not only shrinks the code in nl80211 by     
> almost 5K .text, but also greatly reduces the
> likelihood of future errors.

And by that, I mean locking errors.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
