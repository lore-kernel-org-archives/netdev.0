From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: wcn36xx: Silence error about unsupported smd event 188
Date: Fri, 8 Jul 2016 16:05:05 +0200
Message-ID: <a4318d226b5e422a81772abe9befb423@euamsexm01a.eu.qualcomm.com>
References: <1467902933-28577-1-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	<wcn36xx@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Nicolas Dechesne <nicolas.dechesne@linaro.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467902933-28577-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> wrote:
> Sometimes the firmware sends a HAL_DEL_BA_IND, the prima driver silently
> ignore this message so let's do the same to silence the error message.
> 
> Cc: Nicolas Dechesne <nicolas.dechesne@linaro.org>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Thanks, 1 patch applied to ath-next branch of ath.git:

7860eb7537a0 wcn36xx: Silence error about unsupported smd event 188

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9219071/
