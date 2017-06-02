From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v6 00/21] net-next: stmmac: add dwmac-sun8i
 ethernet driver
Date: Fri, 02 Jun 2017 10:08:01 -0400 (EDT)
Message-ID: <20170602.100801.2029534530888525251.davem@davemloft.net>
References: <20170531071852.12422-1-clabbe.montjoie@gmail.com>
	<20170601.145819.789604139072328057.davem@davemloft.net>
	<20170602063752.aqyvwcykvepiyt4y@flea.lan>
Reply-To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
 wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
 will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
 devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Return-path: <linux-sunxi+bncBCFPF2XH6UDBBRXCYXEQKGQEHTC6UDA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170602063752.aqyvwcykvepiyt4y-ZC1Zs529Oq4@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Date: Fri, 2 Jun 2017 08:37:52 +0200

> On Thu, Jun 01, 2017 at 02:58:19PM -0400, David Miller wrote:
>> From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Wed, 31 May 2017 09:18:31 +0200
>> 
>> > This patch series add the driver for dwmac-sun8i which handle the Ethernet MAC
>> > present on Allwinner H3/H5/A83T/A64 SoCs.
>> 
>> Series applied, but wow that's a lot of DT file changes :-(
> 
> The DT patches should not go through your tree, but arm-soc, so I
> guess this is not an issue for you?

I already applied them, so if that is the intention, too late.

This needs to be explicitly stated in the header posting.  Otherwise
I assume the entire series is meant to go into my tree.

Also, saying "net-next" in the patch subjects means it's targetting my
tree.
