From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [-next] mwifiex: make function mwifiex_ret_pkt_aggr_ctrl static
Date: Tue, 13 Jun 2017 07:01:23 +0000 (UTC)
Message-ID: <20170613070123.14C71607E4@smtp.codeaurora.org>
References: <20170602085639.29338-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602085639.29338-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> function mwifiex_ret_pkt_aggr_ctrl can be made static as it does not
> need to be in global scope.
> 
> Cleans up sparse warning: "symbol 'mwifiex_ret_pkt_aggr_ctrl' was not
> declared. Should it be static?"
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to wireless-drivers-next.git, thanks.

292c333300ec mwifiex: make function mwifiex_ret_pkt_aggr_ctrl static

-- 
https://patchwork.kernel.org/patch/9761985/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
