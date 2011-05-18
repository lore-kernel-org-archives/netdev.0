From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [Patch net-next-2.6] rfkill: remove CONFIG_RFKILL_INPUT
Date: Wed, 18 May 2011 15:47:28 -0700
Message-ID: <1305758848.8827.2.camel@jlt3.sipsolutions.net>
References: <BANLkTin9EbYhOHiU-EwGDTsXegks_hAT_A@mail.gmail.com>
	 (sfid-20110516_124438_617614_6D997BDC)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTin9EbYhOHiU-EwGDTsXegks_hAT_A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20110516_124438_617614_6D997BDC)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-16 at 18:44 +0800, Am=C3=A9rico Wang wrote:
> This is scheduled to be removed in 2.6.33, now we are at 2.6.39-rc2.
> So I think it is safe to remove it completely.

We still don't have urfkill widely deployed, so NAK. 2.6.33 was wishful
thinking.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
