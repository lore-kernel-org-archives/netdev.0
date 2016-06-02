From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: mac80211 2016-06-01
Date: Wed, 01 Jun 2016 17:53:43 -0700 (PDT)
Message-ID: <20160601.175343.1760786915246195795.davem@davemloft.net>
References: <1464775875-10494-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464775875-10494-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed,  1 Jun 2016 12:11:14 +0200

> For now, I have just three fixes for the current cycle.
> 
> One of them, the hwsim one, becomes interesting with some pending
> work to make hwsim work for unprivileged users in namespaces, and
> I don't want to allow them to crash the system ... I'll thus wait
> with that patch until you pull this into net-next also, so I can
> pull it back for mac80211-next.
> 
> Let me know if there's any problem.

Pulled, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
