From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [1/6] wcn36xx: Fold indication payload into message header
Date: Fri, 8 Jul 2016 16:00:37 +0200
Message-ID: <1521d56c490b4e74a67fe6a367a672f6@euamsexm01a.eu.qualcomm.com>
References: <1466403588-7041-1-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	<wcn36xx@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-msm@vger.kernel.org>,
	"Bjorn Andersson" <bjorn.andersson@sonymobile.com>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466403588-7041-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> wrote:
> From: Bjorn Andersson <bjorn.andersson@sonymobile.com>
> 
> Merge the two allocation instead of separately allocating room for the
> indication payload.
> 
> Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Thanks, 5 patches applied to ath-next branch of ath.git:

909aa60c0572 wcn36xx: Fold indication payload into message header
1c41fd5fb751 wcn36xx: Change indication list lock to spinlock
05ddce497c05 wcn36xx: Split mmio space into explicit regions
6f10b4e1e6ad wcn36xx: Correct DXE chip version differentiation
86ceae90d3f9 wcn36xx: Fix up wcn36xx_smd_update_scan_params()

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9186689/
