From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-06-04
Date: Sun, 07 Jun 2009 17:04:38 +0200
Message-ID: <4A2BD706.1040100@hartkopp.net>
References: <20090604152011.GC2839@tuxdriver.com> <20090607.033751.191866033.davem@davemloft.net> <4A2BCC41.1060508@hartkopp.net> <20090607145830.GA2736@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090607145830.GA2736-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Sun, Jun 07, 2009 at 04:18:41PM +0200, Oliver Hartkopp wrote:
>> scripts/kconfig/conf -o arch/x86/Kconfig
>> .config:614:warning: symbol value 'm' invalid for RFKILL_INPUT
> 
> That functionality is no longer available as a module.  If you need
> it, then select Y.
> 
> Hth!

It does! Thanks for the clarification. I'll select CONFIG_RFKILL=y now.

Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
