From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] MAINTAINERS: changes for wireless
Date: Wed, 17 Dec 2014 20:29:21 +0100
Message-ID: <5491D991.30908@broadcom.com>
References: <1418836025-9035-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:56231 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbaLQT3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 14:29:23 -0500
In-Reply-To: <1418836025-9035-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/14 18:07, John W. Linville wrote:
> http://marc.info/?l=linux-wireless&m=141883202530292&w=2
>
> This makes it official... :-)

Let see if I can comment on this patch.

First of all, thanks for the years of service. You already gave the 
heads up few months ago, but now its official. It has been good working 
with you getting rid of eye-sore code in brcm80211 drivers.

> Signed-off-by: John W. Linville<linville@tuxdriver.com>
> ---
>   MAINTAINERS | 19 ++++++++-----------
>   1 file changed, 8 insertions(+), 11 deletions(-)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index fdffe962a16a..e82d31aeb936 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6603,19 +6603,8 @@ L:	netdev@vger.kernel.org
>   S:	Maintained
>
>   NETWORKING [WIRELESS]
> -M:	"John W. Linville"<linville@tuxdriver.com>
>   L:	linux-wireless@vger.kernel.org
>   Q:	http://patchwork.kernel.org/project/linux-wireless/list/
> -T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git
> -S:	Maintained
> -F:	net/mac80211/
> -F:	net/rfkill/
> -F:	net/wireless/
> -F:	include/net/ieee80211*
> -F:	include/linux/wireless.h
> -F:	include/uapi/linux/wireless.h
> -F:	include/net/iw_handler.h
> -F:	drivers/net/wireless/
>
>   NETWORKING DRIVERS
>   L:	netdev@vger.kernel.org
> @@ -6636,6 +6625,14 @@ F:	include/linux/inetdevice.h
>   F:	include/uapi/linux/if_*
>   F:	include/uapi/linux/netdevice.h
>
> +NETWORKING DRIVERS (WIRELESS)
> +M:	Kalle Valo<kvalo@codeaurora.org>
> +L:	linux-wireless@vger.kernel.org
> +Q:	http://patchwork.kernel.org/project/linux-wireless/list/
> +T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git/
> +S:	Maintained
> +F:	drivers/net/wireless/

So what about the other paths that were in "NETWORKING [WIRELESS]". 
Couple of them are obviously maintained by Johannes, but..

> +
>   NETXEN (1/10) GbE SUPPORT
>   M:	Manish Chopra<manish.chopra@qlogic.com>
>   M:	Sony Chacko<sony.chacko@qlogic.com>
