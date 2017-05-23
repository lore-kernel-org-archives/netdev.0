From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [v2] ath10k: remove unnecessary code
Date: Tue, 23 May 2017 17:25:41 +0200
Message-ID: <b5d346a9f0fd483f96b7f0fff6174750@euamsexm01a.eu.qualcomm.com>
References: <20170509125129.GA21962@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <ath10k@lists.infradead.org>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509125129.GA21962@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Gustavo A. R. Silva" <garsilva@embeddedor.com> wrote:
> The array fields in struct wmi_start_scan_arg that are checked here are
> fixed size arrays so they can never be NULL.
> 
> Addresses-Coverity-ID: 1260031
> Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>
> Cc: Kalle Valo <kvalo@qca.qualcomm.com>
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Patch applied to ath-next branch of ath.git, thanks.

8c1f20815231 ath10k: remove unnecessary code

-- 
https://patchwork.kernel.org/patch/9717869/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
