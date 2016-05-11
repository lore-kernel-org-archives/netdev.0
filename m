From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: rtlwifi: rtl818x: constify rtl_intf_ops structures
Date: Wed, 11 May 2016 18:43:18 +0000 (UTC)
Message-ID: <20160511184318.B822E6133D@smtp.codeaurora.org>
References: <1462132664-1619-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462132664-1619-1-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org> wrote:
> The rtl_intf_ops structures are never modified, so declare them as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>

Thanks, 1 patch applied to wireless-drivers-next.git:

1bfcfdcca142 rtlwifi: rtl818x: constify rtl_intf_ops structures

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/8989291/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
