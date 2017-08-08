From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath9k: make ath_ps_ops structures as const
Date: Tue, 8 Aug 2017 13:09:44 +0200
Message-ID: <0d0e2329fed544cf9595c34de5b1f641@euamsexm01a.eu.qualcomm.com>
References: <1501772131-13038-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <ath9k-devel@qca.qualcomm.com>,
        <kvalo@codeaurora.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501772131-13038-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhumika Goyal <bhumirks@gmail.com> wrote:

> ath_ps_ops structures are only stored as a reference in the ps_ops
> field of a ath_common structure. This field is of type const, so make
> the structures as const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

Patch applied to ath-next branch of ath.git, thanks.

3588e1110e49 ath9k: make ath_ps_ops structures as const

-- 
https://patchwork.kernel.org/patch/9879297/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
