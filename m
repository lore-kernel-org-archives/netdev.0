From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] rtlwifi: rtl8192cu: Add new USB ID
Date: Fri, 08 Feb 2013 10:37:57 -0800
Message-ID: <1360348677.2268.7.camel@joe-AO722>
References: <1360348098-8687-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1360348098-8687-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-02-08 at 12:28 -0600, Larry Finger wrote:
> A new model of the RTL8188CUS has appeared.
[]
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
> index 577c0dc..a73a17b 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
> @@ -285,6 +285,7 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
>  	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x817f, rtl92cu_hal_cfg)},
>  	/* RTL8188CUS-VL */
>  	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x818a, rtl92cu_hal_cfg)},
> +	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x819a, rtl92cu_hal_cfg)},
>  	/* 8188 Combo for BC4 */
>  	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x8754, rtl92cu_hal_cfg)},

One day would you please do a s/_VENDOR_/_VENDOR_/g
 
