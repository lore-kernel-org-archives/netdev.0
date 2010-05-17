From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/37] drivers/net/wireless/wl12xx: Use kmemdup
Date: Mon, 17 May 2010 10:47:17 +0300
Message-ID: <AANLkTimPDHCFcMruCqNUZKsbvKuszh5gWA052SgaPTkD@mail.gmail.com>
References: <Pine.LNX.4.64.1005152314540.21345@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.1005152314540.21345-QfmoRoYWmW9knbxzx/v8hQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16 May 2010 00:15, Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org> wrote:
> From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
>
> Use kmemdup when some other buffer is immediately copied into the
> allocated region.

Thanks, looks good to me.

> Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

Acked-by: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
