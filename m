From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: wil6210: use memdup_user
Date: Fri, 19 May 2017 09:55:11 +0200
Message-ID: <40e20134d5f74a06947c24f58893ce0f@euamsexm01a.eu.qualcomm.com>
References: <b5b672573585b51a3acb37231f38db45f5873f60.1493781695.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Maya Erez <qca_merez@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Geliang Tang <geliangtang@gmail.com>,
        <linux-wireless@vger.kernel.org>, <wil6210@qca.qualcomm.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b5b672573585b51a3acb37231f38db45f5873f60.1493781695.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geliang Tang <geliangtang@gmail.com> wrote:
> Use memdup_user() helper instead of open-coding to simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Patch applied to ath-next branch of ath.git, thanks.

9a49290919e1 wil6210: use memdup_user

-- 
https://patchwork.kernel.org/patch/9715009/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
