From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 14 Nov 2006 10:29:23 -0500
Message-ID: <4559E0D3.2050306@garzik.org>
References: <20061108045825.GA15272@tuxdriver.com> <20061108045927.GB15272@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:14272 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965970AbWKNP30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:29:26 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061108045927.GB15272@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit d4f748365129ccfc9dadf6fb14331e45e33cc4ed:
>   John W. Linville:
>         Merge branch 'upstream-fixes' into upstream
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> John W. Linville:
>       wireless: clean-up some "check return code" warnings
> 
> Larry Finger:
>       bcm43xx: remove badness variable and related routine
>       bcm43xx: Remove useless core enable/disable messages
>       ieee80211softmac: fix verbosity when debug disabled
> 
>  drivers/net/wireless/bcm43xx/bcm43xx_main.c   |   56 +++++--------------------
>  drivers/net/wireless/hostap/hostap_pci.c      |    8 +++-
>  drivers/net/wireless/ipw2100.c                |    8 +++-
>  drivers/net/wireless/ipw2200.c                |    8 +++-
>  drivers/net/wireless/orinoco_pci.h            |    7 +++
>  drivers/net/wireless/prism54/islpci_hotplug.c |   20 +++++++--
>  net/ieee80211/softmac/ieee80211softmac_auth.c |   10 ++--
>  7 files changed, 60 insertions(+), 57 deletions(-)

pulled


