From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/16] drivers/net/wireless/wl12xx: Use available error
 codes
Date: Mon, 16 Aug 2010 20:47:56 +0300
Message-ID: <4C6979CC.80107@adurom.com>
References: <Pine.LNX.4.64.1008161825010.19313@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.1008161825010.19313-QfmoRoYWmW9knbxzx/v8hQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/16/2010 07:25 PM, Julia Lawall wrote:
> From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> 
> In each case, error codes are stored in ret, but the return value is always
> 0.  Return ret instead.

Thanks, looks correct to me.

Acked-by: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>

Kalle
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
