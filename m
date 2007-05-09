From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 09 May 2007 18:54:59 -0400
Message-ID: <46425143.9040403@garzik.org>
References: <20070508173907.GH6479@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49665 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755807AbXEIWzC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 18:55:02 -0400
In-Reply-To: <20070508173907.GH6479@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit 5b94f675f57e4ff16c8fda09088d7480a84dcd91:
>   Linus Torvalds (1):
>         Merge master.kernel.org:/.../davem/sparc-2.6
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Daniel Drake (1):
>       zd1211rw: Add ID for ZyXEL AG-225H v2
> 
> Larry Finger (3):
>       ieee80211: add ieee80211_channel_to_freq
>       ieee80211: include frequency in scan results
>       bcm43xx: Remove dead configuration variable CONFIG_947XX
> 
> Matthew Davidson (1):
>       zd1211rw: Add ID for Sitecom WL-117
> 
> Ulrich Kunitz (1):
>       zd1211rw: Added new USB id for Planex GW-US54ZGL
> 
>  drivers/net/wireless/bcm43xx/bcm43xx.h      |   18 +-----
>  drivers/net/wireless/bcm43xx/bcm43xx_dma.c  |    4 -
>  drivers/net/wireless/bcm43xx/bcm43xx_main.c |   81 ---------------------------
>  drivers/net/wireless/bcm43xx/bcm43xx_main.h |   19 ------
>  drivers/net/wireless/zd1211rw/zd_usb.c      |    4 +
>  include/net/ieee80211.h                     |    2 +
>  net/ieee80211/ieee80211_geo.c               |   16 +++++
>  net/ieee80211/ieee80211_wx.c                |    8 ++-
>  8 files changed, 31 insertions(+), 121 deletions(-)

pulled


