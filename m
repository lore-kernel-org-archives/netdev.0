From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: mac80211-next 2017-10-11
Date: Wed, 11 Oct 2017 10:15:31 -0700 (PDT)
Message-ID: <20171011.101531.1673001523626350498.davem@davemloft.net>
References: <20171011123613.28890-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171011123613.28890-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 11 Oct 2017 14:36:12 +0200

> Here's a -next pull request. The only bigger thing here is the
> addition of the regulatory database as firmware, which will
> allow us to - over time - get rid of CRDA, as well as having
> the option of adding more fields to the database where needed,
> this would've been extremely complex with CRDA because it had
> not been built with extensibility in mind.
> 
> Please pull and let me know if there's any problem.

Pulled, thanks!
