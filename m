From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [049/102] ath10k: explicitly request exclusive reset control
Date: Thu, 3 Aug 2017 13:38:11 +0200
Message-ID: <10a2383f853747d5ac59a871502b1404@euamsexm01a.eu.qualcomm.com>
References: <20170719152646.25903-50-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        <ath10k@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Philipp Zabel <p.zabel@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719152646.25903-50-p.zabel@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philipp Zabel <p.zabel@pengutronix.de> wrote:

> Commit a53e35db70d1 ("reset: Ensure drivers are explicit when requesting
> reset lines") started to transition the reset control request API calls
> to explicitly state whether the driver needs exclusive or shared reset
> control behavior. Convert all drivers requesting exclusive resets to the
> explicit API call so the temporary transition helpers can be removed.
> 
> No functional changes.
> 
> Cc: Kalle Valo <kvalo@qca.qualcomm.com>
> Cc: ath10k@lists.infradead.org
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

Patch applied to ath-next branch of ath.git, thanks.

a764284f34f9 ath10k: explicitly request exclusive reset control

-- 
https://patchwork.kernel.org/patch/9852575/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
