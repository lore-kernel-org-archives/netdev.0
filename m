From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: btcoex: 23b 1ant: fix duplicated code for different
 branches
Date: Thu, 24 Aug 2017 09:52:44 +0000 (UTC)
Message-ID: <20170824095244.AFA9F60714@smtp.codeaurora.org>
References: <20170818002219.GA9475@embeddedgus>
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
In-Reply-To: <20170818002219.GA9475@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Gustavo A. R. Silva" <gustavo@embeddedor.com> wrote:

> Refactor code in order to avoid identical code for different branches.
> 
> This issue was detected with the help of Coccinelle.
> 
> Addresses-Coverity-ID: 1415177
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Patch applied to wireless-drivers-next.git, thanks.

14cc696c0a4a rtlwifi: btcoex: 23b 1ant: fix duplicated code for different branches

-- 
https://patchwork.kernel.org/patch/9907397/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
