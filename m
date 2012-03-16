From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH v2 2/4] mac80211:  Support getting sta_info stats via
 ethtool.
Date: Fri, 16 Mar 2012 20:56:23 +0000
Message-ID: <1331931383.2504.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1331927952-8706-1-git-send-email-greearb@candelatech.com>
	 <1331927952-8706-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1331927952-8706-2-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-03-16 at 12:59 -0700, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org wrote:
> From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
> 
> This lets ethtool print out stats related to station
> interfaces.  Does not yet get stats from the underlying
> driver.
[...]

Nice.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
