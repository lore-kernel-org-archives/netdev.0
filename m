From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V12 0/4] ptp: IEEE 1588 hardware clock support
Date: Thu, 03 Mar 2011 12:13:43 -0800 (PST)
Message-ID: <20110303.121343.28802720.davem@davemloft.net>
References: <cover.1298878618.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org,
	arnd-r2nGTMty4D4@public.gmane.org, cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org,
	peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, giometti-k2GhghHVRtY@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org,
	benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org, vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
	linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
To: richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1298878618.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 28 Feb 2011 08:57:03 +0100

> This really might be the last review of the PTP hardware clock patch
> series. These patches apply on top of the timers/core branch in the
> tip tree.

I'm find with the networking portions so:

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

I am assuming these will be pushed through the timers/core branch
since there are dependencies.

Thanks.
