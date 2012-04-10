From: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2] wl12xx: fix DMA-API-related warnings
Date: Tue, 10 Apr 2012 13:19:55 +0300
Message-ID: <1334053195.10398.0.camel@cumari>
References: <1332006114-30230-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mircea Gherzan <mgherzan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1332006114-30230-1-git-send-email-mgherzan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-03-17 at 18:41 +0100, Mircea Gherzan wrote: 
> On the PandaBoard (omap_hsmmc + wl12xx_sdio) with DMA_API_DEBUG:
> 
>  WARNING: at lib/dma-debug.c:930 check_for_stack.part.8+0x7c/0xe0()
>  omap_hsmmc omap_hsmmc.4: DMA-API: device driver maps memory fromstack
> 
> Signed-off-by: Mircea Gherzan <mgherzan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---

Pushed, thanks for fixing this!

-- 
Cheers,
Luca.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
