From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: ipw2200: remove redundant check of rc < 0
Date: Mon, 20 Mar 2017 17:16:41 +0000 (UTC)
Message-ID: <20170320171641.6B24460C78@smtp.codeaurora.org>
References: <20170227234019.19081-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170227234019.19081-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The check for rc < 0 is always false so the check is redundant
> and can be removed.
> 
> Detected with CoverityScan, CID#101143 ("Logically dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to wireless-drivers-next.git, thanks.

889cdff72b85 ipw2200: remove redundant check of rc < 0

-- 
https://patchwork.kernel.org/patch/9594495/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
