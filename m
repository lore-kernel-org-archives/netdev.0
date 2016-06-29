From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: mac80211 2016-06-29-v2
Date: Wed, 29 Jun 2016 08:35:19 -0400 (EDT)
Message-ID: <20160629.083519.1140782026978366981.davem@davemloft.net>
References: <1467194567-19602-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467194567-19602-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 29 Jun 2016 12:02:46 +0200

> Sorry to be sending a new pull request, but Felix had just submitted a
> fairly important fix and I decided I should send it on quickly.
> 
> Now thus we have two fixes, one for the mesh refcounting issue and one
> for an issue with the ethertype/length field being too long when it's
> used as a length, during A-MSDU decapsulation.
> 
> Let me know if there's any problem.

Pulled, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
