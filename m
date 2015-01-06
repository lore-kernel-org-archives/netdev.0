From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: mac80211 2015-01-06
Date: Tue, 06 Jan 2015 13:30:22 -0500 (EST)
Message-ID: <20150106.133022.1374471134166201756.davem@davemloft.net>
References: <1420546548.1966.26.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420546548.1966.26.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 06 Jan 2015 13:15:48 +0100

> Here's just a single fix - a revert of a patch that broke the
> p54 and cw2100 drivers (arguably due to bad assumptions there.)
> Since this affects kernels since 3.17, I decided to revert for
> now and we'll revisit this optimisation properly for -next.

Pulled, thanks Johannes.

> Also -- happy New Year, and sorry about the genl issue :(

No problem.

> I'm still a bit confused about whether you wanted the pull request with
> the text in the email or in the tag, or branch, or something - I
> interpreted what you said to Kalle differently to what you said to me.
> I've duplicated it for now :)

If you put it in the tag, that's fine, I'll just add my signoff to
it.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
