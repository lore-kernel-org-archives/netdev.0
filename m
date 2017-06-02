From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v6 00/21] net-next: stmmac: add dwmac-sun8i
 ethernet driver
Date: Fri, 02 Jun 2017 10:22:05 -0400 (EDT)
Message-ID: <20170602.102205.701672574727845689.davem@davemloft.net>
References: <20170601.145819.789604139072328057.davem@davemloft.net>
	<20170602063752.aqyvwcykvepiyt4y@flea.lan>
	<20170602091320.lyfxsanxrypfpozb@flea.lan>
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
Return-path: <linux-sunxi+bncBCFPF2XH6UDBBEHJYXEQKGQE3ND7V7Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170602091320.lyfxsanxrypfpozb-ZC1Zs529Oq4@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Date: Fri, 2 Jun 2017 11:13:20 +0200

> On Fri, Jun 02, 2017 at 08:37:52AM +0200, Maxime Ripard wrote:
>> On Thu, Jun 01, 2017 at 02:58:19PM -0400, David Miller wrote:
>> > From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> > Date: Wed, 31 May 2017 09:18:31 +0200
>> > 
>> > > This patch series add the driver for dwmac-sun8i which handle the Ethernet MAC
>> > > present on Allwinner H3/H5/A83T/A64 SoCs.
>> > 
>> > Series applied, but wow that's a lot of DT file changes :-(
>> 
>> The DT patches should not go through your tree, but arm-soc, so I
>> guess this is not an issue for you?
> 
> Ok, so I saw that you actually merged them. Can you revert or drop
> that merge for the DT part?
> 
> This will generate a lot of conflicts with our tree, and I'm not sure
> this would be efficient to make you take all the entirely unrelated to
> next patches.

Please tell me which specific changes to revert.

Thank you.
