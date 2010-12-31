From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 03/15]drivers:staging:rtl8187se:r8180_hw.h Typo change
 diable to disable.
Date: Fri, 31 Dec 2010 09:32:32 -0600
Message-ID: <4D1DF790.2010500@lwfinger.net>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com> <1293750484-1161-2-git-send-email-justinmattock@gmail.com> <1293750484-1161-3-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, linux-m68k@lists.linux-m68k.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ivtv-devel@ivtvdriver.org, linux-media@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org,
	spi-devel-general@lists.sourceforge.net,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60331 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab0LaPcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 10:32:33 -0500
In-Reply-To: <1293750484-1161-3-git-send-email-justinmattock@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2010 05:07 PM, Justin P. Mattock wrote:
> The below patch fixes a typo "diable" to "disable". Please let me know if this 
> is correct or not.
> 
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
> 
> ---

ACKed-by: Larry Finger <Larry.Finger@lwfinger.net>

>  drivers/staging/rtl8187se/r8180_hw.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/rtl8187se/r8180_hw.h b/drivers/staging/rtl8187se/r8180_hw.h
> index 3fca144..2911d40 100644
> --- a/drivers/staging/rtl8187se/r8180_hw.h
> +++ b/drivers/staging/rtl8187se/r8180_hw.h
> @@ -554,7 +554,7 @@
>  /* by amy for power save		*/
>  /* by amy for antenna			*/
>  #define EEPROM_SW_REVD_OFFSET 0x3f
> -/*  BIT[8-9] is for SW Antenna Diversity. Only the value EEPROM_SW_AD_ENABLE means enable, other values are diable.					*/
> +/*  BIT[8-9] is for SW Antenna Diversity. Only the value EEPROM_SW_AD_ENABLE means enable, other values are disabled.					*/
>  #define EEPROM_SW_AD_MASK			0x0300
>  #define EEPROM_SW_AD_ENABLE			0x0100
>  

