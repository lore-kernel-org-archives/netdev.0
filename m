From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: cw1200: add const to hwbus_ops structures
Date: Wed, 28 Jun 2017 18:18:01 +0000 (UTC)
Message-ID: <20170628181801.049B560AD5@smtp.codeaurora.org>
References: <1498218199-13429-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, pizza@shaftnet.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498218199-13429-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhumika Goyal <bhumirks@gmail.com> wrote:

> Declare hwbus_ops structures as const as they are only passed as an
> argument to the function cw1200_core_probe. This argument is of type
> const. So, make these structures const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

3ac27dd37b40 cw1200: add const to hwbus_ops structures

-- 
https://patchwork.kernel.org/patch/9806289/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
