From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Wed, 18 Jul 2007 18:31:14 -0400
Message-ID: <469E94B2.7000709@garzik.org>
References: <20070718021953.GC26907@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070718021953.GC26907-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> A few more for 2.6.23...
> 
> Thanks!
> 
> John
> 
> ---
> 
> The following changes since commit 4ad1366376bfef32ec0ffa12d1faa483d6f330bd:
>   NeilBrown (1):
>         md: change bitmap_unplug and others to void functions
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik
> 
> Daniel Drake (1):
>       zd1211rw: Add ID for Siemens Gigaset USB Stick 54
> 
> Jean Tourrilhes (1):
>       softmac: Channel is listed twice in scan output
> 
> Masakazu Mokuno (1):
>       zd1211rw: Add ID for Planex GW-US54GXS
> 
> Zhu Yi (4):
>       ipw2100: Fix `iwpriv set_power` error
>       Fix ipw2200 set wrong power parameter causing firmware error
>       ipw2200: Fix ipw_isr() comments error on shared IRQ
>       Update version ipw2200 stamp to 1.2.2
> 
>  drivers/net/wireless/ipw2100.c         |    6 +++---
>  drivers/net/wireless/ipw2200.c         |   18 ++++++++----------
>  drivers/net/wireless/zd1211rw/zd_usb.c |    2 ++
>  net/ieee80211/ieee80211_wx.c           |    7 ++-----
>  4 files changed, 15 insertions(+), 18 deletions(-)

pulled
