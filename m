From: "Anton.Glukhov" <anton.a.glukhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net, can, ti_hecc: add DT support for the ti,hecc
 controller
Date: Tue, 20 Oct 2015 18:38:06 +0300
Message-ID: <56265FDE.9050307@gmail.com>
References: <1445236757-29019-1-git-send-email-hs@denx.de>
 <56249491.4020009@pengutronix.de> <56249B58.6090100@denx.de>
 <56249C3F.3080000@pengutronix.de> <56265661.7000509@gmail.com>
 <56265852.6000601@pengutronix.de> <56265947.8050008@gmail.com>
 <56265B55.2070203@pengutronix.de> <56265BC4.8080403@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?Q?Beno=c3=aet_Cousson?= <bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
	Anant Gole <anantgole-l0cyMroinI0@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, hs-ynQEQJNshbs@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56265BC4.8080403-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 20.10.2015 18:20, Marc Kleine-Budde wrote:
> On 10/20/2015 05:18 PM, Marc Kleine-Budde wrote:
>> On 10/20/2015 05:09 PM, Anton.Glukhov wrote:
>>>>> It's OMAP3 based arch, but HECC is implemented only in AM3505 and AM3517 SoCs.
>>>>> So, I'm confused about what's "name" should I use.
>>>>
>>>> Which SoC was available first? Pick that.
>>
>>> What do you mean available? I know only that HECC appear in AM3505 and AM3517. Nowhere else.
>>
>> Available on the market. Which one was produced first or was soldered
>> first to some PCB?
> 
> A colleague just looked it up, a AM3517 is a AM3505 with 3d graphics. So
> pick AM3505.

Ok, thank you for help!

> 
> Marc
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
