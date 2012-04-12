From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 00/10] Wireless patches for wireless-testing
Date: Thu, 12 Apr 2012 05:39:56 +0200
Message-ID: <1334201996.3788.3.camel@jlt3.sipsolutions.net>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
	 (sfid-20120411_195246_310207_9F34AD4B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334166738-28243-1-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org> (sfid-20120411_195246_310207_9F34AD4B)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-04-11 at 10:52 -0700, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org wrote:
> From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
> 
> Support Ethtool stats for Wireless, including in-depth
> stats for ath9k, and add some additional ath9k stats
> to debugfs.  Support scanning on-channel.

Please don't mix two completely different things in a single series of
patches. I almost skipped this completely since I already saw the
ethtool stuff and don't care about ath9k stats, but clearly I need to
look at the scan thing ...

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
