From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath10k: make ath10k_hw_ce_regs const
Date: Mon, 25 Sep 2017 09:16:05 +0200
Message-ID: <7dc5dd650ee340bb9d2e96287e1c4ece@euamsexm01a.eu.qualcomm.com>
References: <1505329312-26432-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <ath10k@lists.infradead.org>,
        <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505329312-26432-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhumika Goyal <bhumirks@gmail.com> wrote:

> Make them const as they are not modified in the file referencing
> them. They are only stored in the const field 'hw_ce_reg' of an ath10k
> structure. Also, make the declarations in the header const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

Patch applied to ath-next branch of ath.git, thanks.

496cbf3ebb6b ath10k: make ath10k_hw_ce_regs const

-- 
https://patchwork.kernel.org/patch/9951901/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
