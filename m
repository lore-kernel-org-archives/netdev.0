From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH v2 2/3] net: Add Keystone NetCP ethernet driver
Date: Thu, 21 Aug 2014 19:48:38 -0700
Message-ID: <20140821194838.32f2c3f1@uryu.home.lan>
References: <1408115562-22487-1-git-send-email-santosh.shilimkar@ti.com>
	<1408115562-22487-3-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<sandeep_n-l0cyMroinI0@public.gmane.org>
To: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1408115562-22487-3-git-send-email-santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Aug 2014 11:12:41 -0400
Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org> wrote:

> NetCP driver has a plug-in module architecture where each of the NetCP
> sub-modules exist as a loadable kernel module which plug in to the netcp
> core. These sub-modules are represented as "netcp-devices" in the dts
> bindings. It is mandatory to have the ethernet switch sub-module for
> the ethernet interface to be operational. Any other sub-module like the
> PA is optional.

What are you doing to prevent/discourage proprietary binary only
sub-modules?
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
