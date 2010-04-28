From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2010-04-15
Date: Wed, 28 Apr 2010 14:23:23 -0700 (PDT)
Message-ID: <20100428.142323.91321737.davem@davemloft.net>
References: <20100415200331.GD3020@tuxdriver.com>
	<20100415.142907.68448693.davem@davemloft.net>
	<4BD8A6B4.20603@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4BD8A6B4.20603-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Date: Wed, 28 Apr 2010 23:20:52 +0200

> Hi David,
> 
> in your merge in 5c01d5669356e13f0fb468944c1dd4c6a7e978ad you added "int
> i;" into wl1271_main.c which is unused in that function.
> 
> This patch fixes the merge problem:
> 
> Signed-off-by: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
