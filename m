From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: wl18xx: add checks on wl18xx_top_reg_write() return value
Date: Wed, 28 Jun 2017 18:18:53 +0000 (UTC)
Message-ID: <20170628181853.7BFC460AD2@smtp.codeaurora.org>
References: <20170626230619.GA14831@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
To: "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170626230619.GA14831@embeddedgus>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org> wrote:

> Check return value from call to wl18xx_top_reg_write(),
> so in case of error jump to goto label out and return.
> 
> Also, remove unnecessary value check before goto label out.
> 
> Addresses-Coverity-ID: 1226938
> Signed-off-by: Gustavo A. R. Silva <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

059c98599b1a wl18xx: add checks on wl18xx_top_reg_write() return value

-- 
https://patchwork.kernel.org/patch/9810591/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
