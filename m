From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: mac80211-next 2016-10-28
Date: Sat, 29 Oct 2016 17:27:24 -0400 (EDT)
Message-ID: <20161029.172724.617624040118729651.davem@davemloft.net>
References: <20161028070614.17583-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161028070614.17583-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Fri, 28 Oct 2016 09:06:13 +0200

> First update for 4.10 - nothing major, new features as usual (FILS), and
> sometimes we deprecate old stuff (WDS).
> 
> I don't have the fixes for the on-stack crypto/SG handling in this tree
> (you already have them via mac80211.git), but we did make sure that the
> fils_aead code doesn't re-introduce such an issue.
> 
> Please pull and let me know if there's any problem.

Pulled, thanks Johannes.
