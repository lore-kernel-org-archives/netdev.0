From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath10k: add const to thermal_cooling_device_ops structure
Date: Wed, 28 Jun 2017 18:54:01 +0200
Message-ID: <ba4938bc024149c4a5bbb36dd2c66fef@euamsexm01a.eu.qualcomm.com>
References: <1498037010-21024-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <ath10k@lists.infradead.org>,
        <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498037010-21024-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhumika Goyal <bhumirks@gmail.com> wrote:

> Declare thermal_cooling_device_ops structure as const as it is only passed
> as an argument to the function thermal_cooling_device_register and this
> argument is of type const. So, declare the structure as const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

Patch applied to ath-next branch of ath.git, thanks.

1cdb6c9fd433 ath10k: add const to thermal_cooling_device_ops structure

-- 
https://patchwork.kernel.org/patch/9801291/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
