From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: Remove seq_number from rtl_tid_data
Date: Fri, 27 Oct 2017 08:03:32 +0000 (UTC)
Message-ID: <20171027080332.4D141601EA@smtp.codeaurora.org>
References: <20171024020331.7353-1-pkshih@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <Larry.Finger@lwfinger.net>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <yhchuang@realtek.com>, <pkshih@realtek.com>
To: Ping-Ke Shih <pkshih@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40190 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdJ0IDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 04:03:32 -0400
In-Reply-To: <20171024020331.7353-1-pkshih@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping-Ke Shih <pkshih@realtek.com> wrote:

> From: Ping-Ke Shih <pkshih@realtek.com>
> 
> Since mac80211 maintains the sequence number for each STA/TID,
> driver doesn't need to maintain a copy.
> 
> Signed-off-by: Ping-Ke Shih <pkshih@realtek.com>

Patch applied to wireless-drivers-next.git, thanks.

1d1aa8f1ea24 rtlwifi: Remove seq_number from rtl_tid_data

-- 
https://patchwork.kernel.org/patch/10023425/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
