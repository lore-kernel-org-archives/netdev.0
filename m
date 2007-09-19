From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Wed, 19 Sep 2007 13:12:06 -0700 (PDT)
Message-ID: <20070919.131206.102575245.davem@davemloft.net>
References: <20070919.115903.75429061.davem@davemloft.net>
	<200709192123.16884.mb@bu3sch.de>
	<20070919.125641.62342823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070919.125641.62342823.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Wed, 19 Sep 2007 12:56:41 -0700 (PDT)

> I agreed with John to merge this in myself, but this patch
> applied to the old driver aparently, not the new z1211 one.
> 
> Can you resend this patch against the new driver so I can
> add it to net-2.6.24?

Nevermind, John showed me that if I just edit the paths
in the patch it applied cleanly.

So I did that and pushed it to net-2.6.24, thanks!
