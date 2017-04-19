From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath9k: Add cast to u8 to FREQ2FBIN macro
Date: Wed, 19 Apr 2017 16:01:22 +0200
Message-ID: <cc9e31d8452d4d24a24d56467b8b409c@euamsexm01a.eu.qualcomm.com>
References: <20170406212135.72157-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        ath9k Development <ath9k-devel@qca.qualcomm.com>,
        <linux-kernel@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, Grant Grundler <grundler@chromium.org>,
        Matthias Kaehlcke <mka@chromium.org>
To: Matthias Kaehlcke <mka@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170406212135.72157-1-mka@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthias Kaehlcke <mka@chromium.org> wrote:
> The macro results are assigned to u8 variables/fields. Adding the cast
> fixes plenty of clang warnings about "implicit conversion from 'int' to
> 'u8'".
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

Patch applied to ath-next branch of ath.git, thanks.

627871b71c89 ath9k: Add cast to u8 to FREQ2FBIN macro

-- 
https://patchwork.kernel.org/patch/9668479/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
