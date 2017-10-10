From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: net/wireless/ray_cs: Convert timers to use
Date: Tue, 10 Oct 2017 08:26:03 +0000 (UTC)
Message-ID: <20171010082603.6B3EA60723@smtp.codeaurora.org>
References: <20171005005020.GA23219@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005005020.GA23219@beast>
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
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Kees Cook <keescook@chromium.org>

I'll apply this once I have fast forwarded wireless-drivers-next to
-rc3. I'll also fix the title, what was it supposed to say?

Patch set to Awaiting Upstream.

-- 
https://patchwork.kernel.org/patch/9986253/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
