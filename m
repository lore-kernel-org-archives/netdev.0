From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wireless: ipw2x00: make iw_handler_def const
Date: Thu, 24 Aug 2017 09:59:13 +0000 (UTC)
Message-ID: <20170824095913.CE6AC602B3@smtp.codeaurora.org>
References: <1503491802-1361-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, stas.yakovlev@gmail.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503491802-1361-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhumika Goyal <bhumirks@gmail.com> wrote:

> Make these const as they are only stored in the const field of a
> net_device structure.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

2c1dca3c6b22 wireless: ipw2x00: make iw_handler_def const

-- 
https://patchwork.kernel.org/patch/9917307/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
