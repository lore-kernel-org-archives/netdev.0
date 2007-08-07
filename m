From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Tue, 07 Aug 2007 17:25:12 -0400
Message-ID: <46B8E338.9070405@garzik.org>
References: <20070806201441.GJ6442@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070806201441.GJ6442-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit d4ac2477fad0f2680e84ec12e387ce67682c5c13:
>   Linus Torvalds (1):
>         Linux 2.6.23-rc2
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik
> 
> John W. Linville (1):
>       Revert "[PATCH] bcm43xx: Fix deviation from specifications in set_baseband_attenuation"
> 
> Masakazu Mokuno (1):
>       remove duplicated ioctl entries in compat_ioctl.c
> 
> Michael Buesch (1):
>       softmac: Fix deadlock of wx_set_essid with assoc work
> 
> Michael Wu (1):
>       rtl8187: ensure priv->hwaddr is always valid
> 
> Ulrich Kunitz (1):
>       zd1211rw: fix filter for PSPOLL frames
> 
>  drivers/net/wireless/bcm43xx/bcm43xx_phy.c  |    2 +-
>  drivers/net/wireless/rtl8187_dev.c          |    2 +-
>  drivers/net/wireless/zd1211rw/zd_mac.c      |    2 +-
>  fs/compat_ioctl.c                           |    3 ---
>  net/ieee80211/softmac/ieee80211softmac_wx.c |   11 ++++++++---
>  5 files changed, 11 insertions(+), 9 deletions(-)

pulled
