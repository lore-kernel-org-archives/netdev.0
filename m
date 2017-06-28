From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: ti: wl18xx: add checks on wl18xx_top_reg_write() return value
Date: Wed, 28 Jun 2017 16:38:44 +0000 (UTC)
Message-ID: <20170628163844.455B5605BD@smtp.codeaurora.org>
References: <20170626230619.GA14831@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170626230619.GA14831@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Gustavo A. R. Silva" <garsilva@embeddedor.com> wrote:

> Check return value from call to wl18xx_top_reg_write(),
> so in case of error jump to goto label out and return.
> 
> Also, remove unnecessary value check before goto label out.
> 
> Addresses-Coverity-ID: 1226938
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

The prefix should be "wl18xx:", I'll fix that.

-- 
https://patchwork.kernel.org/patch/9810591/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
