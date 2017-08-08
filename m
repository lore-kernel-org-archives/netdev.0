From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] rtlwifi: constify rate_control_ops structure
Date: Tue,  8 Aug 2017 11:53:22 +0000 (UTC)
Message-ID: <20170808115322.4155160209@smtp.codeaurora.org>
References: <1502082051-4904-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, Larry.Finger@lwfinger.net,
        chaoming_li@realsil.com.cn, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502082051-4904-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhumika Goyal <bhumirks@gmail.com> wrote:

> rate_control_ops structure is only passed as an argument to the
> function ieee80211_rate_control_{register/unregister}. This argument
> is of type const, so declare the structure as const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

cb1b82625de7 rtlwifi: constify rate_control_ops structure

-- 
https://patchwork.kernel.org/patch/9884393/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
