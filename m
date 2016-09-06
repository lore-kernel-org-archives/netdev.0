From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v4 1/4] soc: qcom: wcnss_ctrl: Stub wcnss_ctrl API
Date: Wed, 7 Sep 2016 00:12:42 +0100
Message-ID: <4378F670-3784-457F-A070-4B56A8178E68@holtmann.org>
References: <1473200312-22438-1-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Andy Gross <andy.gross@linaro.org>,
        Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>, wcn36xx@lists.infradead.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-arm-msm@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473200312-22438-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

> Stub the wcnss_ctrl API to allow compile testing wcnss function drivers.
> 
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> ---
> 
> There are no other pending changes colliding with this, so if Andy is okay with
> this it could be merged through Kalle's tree - together with the other patches.
> 
> Marcel, with this applied we can drop the depends on QCOM_SMD from the
> btqcomsmd driver as well.

sounds great. As soon as this lands in net-next, then please send a patch to remove the dependency. I will pull in net-next into bluetooth-next then.

Regards

Marcel
