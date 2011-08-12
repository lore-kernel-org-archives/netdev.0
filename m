From: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 2/9] drivers/net/wireless/wl12xx: add missing kfree
Date: Fri, 12 Aug 2011 08:14:01 +0300
Message-ID: <1313126041.2407.911.camel@cumari>
References: <1312802283-9107-2-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1312802283-9107-2-git-send-email-julia-dAYI7NvHqcQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-08-08 at 13:17 +0200, Julia Lawall wrote: 
> From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> 
> In each case, the freed data should be freed in the error handling code as
> well.

[...]

> Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> 
> ---

John, since you took Julia's patch for wl1251 into 3.1, could you also
take this patch into it, please?

Acked-by: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>

-- 
Cheers,
Luca.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
