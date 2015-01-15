From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH] rtlwifi: rtl8192ee: New firmware from Realtek
Date: Thu, 15 Jan 2015 14:21:27 -0500
Message-ID: <20150115192127.GA30928@merlin.infradead.org>
References: <1421270679-3029-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-firmware@kernel.org, linux-wireless@vger.kernel.org,
	Troy Tan <troy_tan@realsil.com.cn>, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:34222 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146AbbAOTVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 14:21:31 -0500
Content-Disposition: inline
In-Reply-To: <1421270679-3029-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 03:24:39PM -0600, Larry Finger wrote:
> From: Troy Tan <troy_tan@realsil.com.cn>
> 
> Recent testing by Realtek found bugs in both the driver and firmware for
> the RTL8192EE chips.
> 
> Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  WHENCE                  |   5 ++++-
>  rtlwifi/rtl8192eefw.bin | Bin 32754 -> 31818 bytes
>  2 files changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/WHENCE b/WHENCE
> index df2dffa..c6f650e 100644
> --- a/WHENCE
> +++ b/WHENCE
> @@ -2115,7 +2115,10 @@ Licence: Redistributable. See LICENCE.rtlwifi_firmware.txt for details.
>  
>  Driver: rtl8192ee - Realtek 802.11n WLAN driver for RTL8192EE
>  
> -Info: Taken from Realtek version rtl_92ce_92se_92de_8723ae_88ee_8723be_92ee_linux_mac80211_0017.1224.2013
> +Info: Initial version taken from Realtek version
> +      rtl_92ce_92se_92de_8723ae_88ee_8723be_92ee_linux_mac80211_0017.1224.2013
> +      Updated Jan. 14, 2015 with file added by Realtek to
> +      http://github.com/lwfinger/rtlwifi_new.git.
>  File: rtlwifi/rtl8192eefw.bin
>  

Looks good, applied. Thanks Larry.

regards, Kyle
