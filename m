From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rsi: remove memset before memcpy
Date: Wed, 30 Aug 2017 16:51:44 +0000 (UTC)
Message-ID: <20170830165144.5D82E60209@smtp.codeaurora.org>
References: <1504032890-25229-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amit.karwar@redpinesignals.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Himanshu Jha <himanshujha199640@gmail.com>
To: Himanshu Jha <himanshujha199640@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504032890-25229-1-git-send-email-himanshujha199640@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Himanshu Jha <himanshujha199640@gmail.com> wrote:

> calling memcpy immediately after memset with the same region of memory
> makes memset redundant.
> 
> Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

66a3479e1217 rsi: remove memset before memcpy

-- 
https://patchwork.kernel.org/patch/9927943/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
