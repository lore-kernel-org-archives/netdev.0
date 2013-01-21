From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] cdc_ncm: add support FLAG_NOARP for Infineon modem
 platform
Date: Mon, 21 Jan 2013 14:25:08 -0500 (EST)
Message-ID: <20130121.142508.838108457248759478.davem@davemloft.net>
References: <1358784032-3897-1-git-send-email-cpuwolf@gmail.com>
	<1358784032-3897-2-git-send-email-cpuwolf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, peter-Y+HMSxxDrH8@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358784032-3897-2-git-send-email-cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 22 Jan 2013 00:00:32 +0800

> Infineon(now Intel) HSPA Modem platform NCM cannot support ARP.
> we can define a new common structure wwan_noarp_info.
> Then more similiar NO ARP devices can be handled easily
> 
> Signed-off-by: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
