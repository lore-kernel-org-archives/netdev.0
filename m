From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] MAINTAINERS: Add networking wireless drivers section
Date: Tue, 28 Jul 2009 11:15:52 -0700
Message-ID: <20090728111552.528a2c9a.randy.dunlap@oracle.com>
References: <Pine.LNX.4.64.0907281753540.28189@ask.diku.dk>
	<20090728.103044.179053537.davem@davemloft.net>
	<1248804397.18284.5.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, julia-dAYI7NvHqcQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1248804397.18284.5.camel-AkRN8/LKpobuYGix6ZUp1Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Jul 2009 11:06:37 -0700 Joe Perches wrote:

> On Tue, 2009-07-28 at 10:30 -0700, David Miller wrote:
> > Wireless patches need to be CC:'d to linux-wireless so that
> > John Linville can notice and pick them up
> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index ebc2691..0574aad 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4186,6 +4186,12 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
>  S:	Odd Fixes
>  F:	drivers/net/
>  
> +NETWORKING WIRELESS DRIVERS
> +L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> +T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
> +S:	Odd Fixes
> +F:	drivers/net/wireless/
> +

Already have this:

NETWORKING [WIRELESS]
P:	John W. Linville
M:	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
S:	Maintained
F:	net/wireless/
F:	include/net/ieee80211*
F:	include/linux/wireless.h


---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
