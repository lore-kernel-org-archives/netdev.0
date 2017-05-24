From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: libertas: Remove function entry/exit debugging
Date: Wed, 24 May 2017 13:44:58 +0000 (UTC)
Message-ID: <20170524134459.07E53602B8@smtp.codeaurora.org>
References: <20170515213317.GA45562@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Joe Perches <joe@perches.com>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170515213317.GA45562@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> wrote:
> In at least one place, the enter/exit debugging was not being correctly
> matched. Based on mailing list feedback, it was desired to drop all of
> these in favor of using ftrace instead.
> 
> Suggested-by: Joe Perches <joe@perches.com>
> Suggested-by: Kalle Valo <kvalo@codeaurora.org>
> Signed-off-by: Kees Cook <keescook@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

4bc606af9fab libertas: Remove function entry/exit debugging

-- 
https://patchwork.kernel.org/patch/9728087/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
