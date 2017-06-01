From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [net-next] qtnfmac: remove duplicated assignment to mac
Date: Thu,  1 Jun 2017 09:50:30 +0000 (UTC)
Message-ID: <20170601095030.463D260779@smtp.codeaurora.org>
References: <20170525134503.12106-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Huizhao Wang <hwang@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170525134503.12106-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> mac is being assigned twice, remove redundant 2nd assignment.
> 
> Detected by CoverityScan, CID#1437554 ("Incorrect expression")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Acked-by: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>

Patch applied to wireless-drivers-next.git, thanks.

4f8e25458cb6 qtnfmac: remove duplicated assignment to mac

-- 
https://patchwork.kernel.org/patch/9748407/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
