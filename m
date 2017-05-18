From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wlcore: use memdup_user
Date: Thu, 18 May 2017 13:41:44 +0000 (UTC)
Message-ID: <20170518134144.2AE9260F5C@smtp.codeaurora.org>
References: <69124563157776eb4187fa35b0161dc8675ebeaf.1493781907.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Colin Ian King <colin.king@canonical.com>,
        Geliang Tang <geliangtang@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <69124563157776eb4187fa35b0161dc8675ebeaf.1493781907.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geliang Tang <geliangtang@gmail.com> wrote:
> Use memdup_user() helper instead of open-coding to simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

6a01d48d47c8 wlcore: use memdup_user

-- 
https://patchwork.kernel.org/patch/9715005/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
