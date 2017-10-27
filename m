From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: drivers/wireless: ath: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 15:55:14 +0200
Message-ID: <7f6d49062e354d07a23971bd4388c513@euamsexm01a.eu.qualcomm.com>
References: <20171024092954.GA47365@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024092954.GA47365@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> wrote:

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Kalle Valo <kvalo@qca.qualcomm.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

Patch applied to ath-next branch of ath.git, thanks.

7ac767645ab1 ath: Convert timers to use timer_setup()

-- 
https://patchwork.kernel.org/patch/10023835/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
