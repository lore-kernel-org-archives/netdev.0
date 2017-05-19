From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [v2] ath9k: remove unnecessary code
Date: Fri, 19 May 2017 09:58:17 +0200
Message-ID: <e681a4945fe04738af9a9f58263f059d@euamsexm01a.eu.qualcomm.com>
References: <20170509130430.GA22190@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509130430.GA22190@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Gustavo A. R. Silva" <garsilva@embeddedor.com> wrote:
> The array field eeprom_data in struct th9k_platform_data
> is a fixed size array so it can never be NULL.
> 
> Addresses-Coverity-ID: 1364903
> Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>
> Cc: Kalle Valo <kvalo@qca.qualcomm.com>
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Patch applied to ath-next branch of ath.git, thanks.

641c1f4ab7f6 ath9k: remove unnecessary code

-- 
https://patchwork.kernel.org/patch/9717873/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
