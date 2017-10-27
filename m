From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: iwlegacy: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 07:45:07 +0000 (UTC)
Message-ID: <20171027074507.99FF060542@smtp.codeaurora.org>
References: <20171024092845.GA47078@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024092845.GA47078@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> wrote:

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: Stanislaw Gruszka <sgruszka@redhat.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

2b77839b3734 iwlegacy: Convert timers to use timer_setup()

-- 
https://patchwork.kernel.org/patch/10023849/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
