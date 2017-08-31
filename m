From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: rtl8723be: fix duplicated code for different branches
Date: Thu, 31 Aug 2017 13:00:20 +0000 (UTC)
Message-ID: <20170831130020.259C56182F@smtp.codeaurora.org>
References: <20170830170424.GA19424@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830170424.GA19424@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Gustavo A. R. Silva" <gustavo@embeddedor.com> wrote:

> Refactor code in order to avoid identical code for different branches.
> 
> Addresses-Coverity-ID: 1248728
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Patch applied to wireless-drivers-next.git, thanks.

a9a65a6b2b69 rtlwifi: rtl8723be: fix duplicated code for different branches

-- 
https://patchwork.kernel.org/patch/9930325/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
