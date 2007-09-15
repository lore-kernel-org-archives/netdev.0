From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Sat, 15 Sep 2007 19:29:48 -0400
Message-ID: <46EC6AEC.40408@garzik.org>
References: <20070915131452.GA6060@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53206 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145AbXIOX3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2007 19:29:50 -0400
In-Reply-To: <20070915131452.GA6060@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Jeff,
> 
> Two more fixes for 2.6.23, including one for kernel.org bug 8937...
> 
> Thanks,
> 
> John
> 
> ---
> 
> The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
>   Linus Torvalds (1):
>         Linux 2.6.23-rc6
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik
> 
> Larry Finger (1):
>       bcm43xx: Fix cancellation of work queue crashes
> 
> Masakazu Mokuno (1):
>       As struct iw_point is bi-directional payload, we should copy back the content
> 
>  drivers/net/wireless/bcm43xx/bcm43xx_main.c  |   28 ++++++++++++++++++-------
>  drivers/net/wireless/bcm43xx/bcm43xx_main.h  |    2 +-
>  drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c |    2 +-
>  fs/compat_ioctl.c                            |   22 ++++++++++++++++---
>  4 files changed, 40 insertions(+), 14 deletions(-)

pulled

