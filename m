From: Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: Re: [PATCH 3.6-rc3 v2] wlcore: Declare MODULE_FIRMWARE usage
Date: Fri, 28 Sep 2012 11:49:49 +0300
Message-ID: <1348822189.15949.5.camel@cumari.coelho.fi>
References: <1346266668.3935.23.camel@cumari.coelho.fi>
	 <1346267373-19591-1-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1346267373-19591-1-git-send-email-tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-08-29 at 13:09 -0600, Tim Gardner wrote:
> Declare any firmware that might be used by this driver.
> If all drivers declare their firmware usage, then a sufficiently
> complete list of firmware files can then be used to pare down
> the external linux-firmware package to just the files in actual use.
> 
> Cc: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---

Applied, thank you!

--
Luca.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
