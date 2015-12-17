From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: add Qualcomm IPC router
Date: Wed, 16 Dec 2015 19:16:47 -0500 (EST)
Message-ID: <20151216.191647.857597925395214968.davem@davemloft.net>
References: <1449866519-14551-1-git-send-email-bjorn.andersson@sonymobile.com>
	<20151215.160114.1178824607335349574.davem@davemloft.net>
	<20151217000141.GG28026@sonymobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Bjorn.Andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	srinivas.kandagatla-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: courtney.cavin-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151217000141.GG28026-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Courtney Cavin <courtney.cavin-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
Date: Wed, 16 Dec 2015 16:01:41 -0800

> We could hardcode the value in kconfig, but that seems like a worse
> solution than a module parameter.
> 
> I'm open to further suggestions.

No module parameters, configure it via netlink or similar at run
time.
