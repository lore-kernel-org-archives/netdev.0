From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Sat, 25 Aug 2007 02:40:39 -0400
Message-ID: <46CFCEE7.4080009@garzik.org>
References: <20070815003637.GK7198@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070815003637.GK7198-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> A few items intended for 2.6.24.
> 
> Individual patches here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-jgarzik/
> 
> Thanks!
> 
> John
> 
> ---
> 
> The following changes since commit 39d3520c92cf7a28c07229ca00cc35a1e8026c77:
>   Linus Torvalds (1):
>         Linux 2.6.23-rc3
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik
> 
> Daniel Drake (2):
>       zd1211rw: Add ID for Sitecom WL-162
>       zd1211rw: Add ID for ZyXEL M-202 XtremeMIMO
> 
> Mariusz Kozlowski (1):
>       drivers/net/wireless/wl3501_cs.c: remove redundant memset
> 
> Ulrich Kunitz (2):
>       zd1211rw: removed noisy debug messages
>       zd1211rw: consistent handling of ZD1211 specific rates
> 
>  drivers/net/wireless/wl3501_cs.c             |    1 -
>  drivers/net/wireless/zd1211rw/zd_chip.c      |   69 +++++++-----------
>  drivers/net/wireless/zd1211rw/zd_ieee80211.h |   43 +++++++----
>  drivers/net/wireless/zd1211rw/zd_mac.c       |   99 +++++++-------------------
>  drivers/net/wireless/zd1211rw/zd_mac.h       |   65 +++++++++++------
>  drivers/net/wireless/zd1211rw/zd_usb.c       |    2 +
>  6 files changed, 128 insertions(+), 151 deletions(-)

pulled
