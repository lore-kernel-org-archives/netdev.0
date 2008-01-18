From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Fri, 18 Jan 2008 14:40:59 -0500
Message-ID: <479100CB.3090800@garzik.org>
References: <20080116212752.GE3164@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52246 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758518AbYARTlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 14:41:01 -0500
In-Reply-To: <20080116212752.GE3164@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John W. Linville wrote:
> Jeff,
> 
> A few more fixes for 2.6.24...note that this branch is based
> on 2.6.24-rc8.
> 
> Thanks,
> 
> John
> 
> ---
> 
> Individual patches available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik/
> 
> ---
> 
> The following changes since commit cbd9c883696da72b2b1f03f909dbacc04bbf8b58:
>   Linus Torvalds (1):
>         Linux 2.6.24-rc8
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik
> 
> Ivo van Doorn (1):
>       rt2x00: Fix ieee80211 payload alignment
> 
> Marc Pignat (1):
>       wireless/libertas support for 88w8385 sdio older revision
> 
> Randy Dunlap (1):
>       hostap: section mismatch warning
> 
> Stefano Brivio (2):
>       ipw2200: fix typo in kerneldoc
>       b43: fix use-after-free rfkill bug
> 
>  drivers/net/wireless/b43/rfkill.c        |   11 ++++++-----
>  drivers/net/wireless/hostap/hostap_plx.c |    6 +++---
>  drivers/net/wireless/ipw2200.c           |    2 +-
>  drivers/net/wireless/libertas/if_sdio.c  |    4 ++++
>  drivers/net/wireless/rt2x00/rt2x00pci.c  |    2 +-
>  drivers/net/wireless/rt2x00/rt2x00usb.c  |   11 +++++++++--
>  6 files changed, 24 insertions(+), 12 deletions(-)

pulled


