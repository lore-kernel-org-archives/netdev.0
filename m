From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: remove useless code
Date: Tue, 18 Jul 2017 20:35:39 -0500
Message-ID: <e30fe757-52cd-ce07-afc6-f9070de9923d@lwfinger.net>
References: <20170718204106.GA9905@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170718204106.GA9905@embeddedgus>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/18/2017 03:41 PM, Gustavo A. R. Silva wrote:
> Remove useless local variables last_read_point and last_txw_point and
> the code related.
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
>   drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c | 6 ------
>   1 file changed, 6 deletions(-)

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks,

Larry
