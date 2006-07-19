From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 19 Jul 2006 13:51:44 -0400
Message-ID: <44BE7130.6050909@garzik.org>
References: <20060710212900.GF13775@tuxdriver.com> <20060710213101.GG13775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41349 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030213AbWGSRvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 13:51:48 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060710213101.GG13775@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> These patches are to be queued for 2.6.19...
> 
> ---
> 
> The following changes since commit b312d799b324e895745ffe148def234fc60d5b74:
>   Daniel Drake:
>         zd1211rw: usb_clear_halt not allowed in IRQ context
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Daniel Drake:
>       zd1211rw: Add Sagem device ID's
> 
> Larry Finger:
>       bcm43xx: improved statistics
> 
> Michael Buesch:
>       bcm43xx: opencoded locking
>       bcm43xx: voluntary preemtion in the calibration loops
> 
>  drivers/net/wireless/bcm43xx/bcm43xx.h         |   64 ++-------
>  drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c |   34 +++--
>  drivers/net/wireless/bcm43xx/bcm43xx_leds.c    |   10 +
>  drivers/net/wireless/bcm43xx/bcm43xx_main.c    |   64 +++++----
>  drivers/net/wireless/bcm43xx/bcm43xx_phy.c     |   33 +++--
>  drivers/net/wireless/bcm43xx/bcm43xx_pio.c     |    4 -
>  drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c   |   34 +++--
>  drivers/net/wireless/bcm43xx/bcm43xx_wx.c      |  162 ++++++++++++++----------
>  drivers/net/wireless/zd1211rw/zd_usb.c         |    2 

pulled


