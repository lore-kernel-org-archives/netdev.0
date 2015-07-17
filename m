From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull-request: mac80211 2015-07-17
Date: Fri, 17 Jul 2015 15:35:04 +0200
Message-ID: <1437140104.1933.19.camel@sipsolutions.net>
References: <1437139894.1933.16.camel@sipsolutions.net>
	 (sfid-20150717_153149_337845_B05B138A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1437139894.1933.16.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> (sfid-20150717_153149_337845_B05B138A)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-07-17 at 15:31 +0200, Johannes Berg wrote:
> Hi Dave,
> 
> We've accumulated some wireless fixes, please pull. Arik's fix is a 
> bit
> bigger than I might like, but it fixes a real locking issue and we
> didn't really see a good way to make a smaller version.
> 
> Let me know if there's any problem.

Also, I'm going to be on vacation starting Tuesday, back on August 10.

I'm merging things to mac80211-next, but I'll hold the pull request
until after I return so I can deal with any possible issues in net-next
more quickly.

Kalle has graciously agreed to handle any urgent bugfixes to mac80211
while I'm out, and will probably send them to you as patches (if
necessary.)

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
