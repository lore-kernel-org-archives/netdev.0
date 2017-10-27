From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [08/58] net/wireless/ray_cs: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 07:31:22 +0000 (UTC)
Message-ID: <20171027073122.A4935600ED@smtp.codeaurora.org>
References: <1508200182-104605-9-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-9-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> wrote:

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

I see that Dave already applied this so dropping it from my queue.

Patch set to Not Applicable.

-- 
https://patchwork.kernel.org/patch/10010421/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
