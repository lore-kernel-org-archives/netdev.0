From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: rtl8821ae: Fix typo in variable name
Date: Fri, 27 Oct 2017 08:02:41 +0000 (UTC)
Message-ID: <20171027080241.175AF60116@smtp.codeaurora.org>
References: <20171024014909.7347-1-nikolas@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, trivial@kernel.org,
        Nik Nyby <nikolas@gnu.org>
To: Nik Nyby <nikolas@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40064 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdJ0ICl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 04:02:41 -0400
In-Reply-To: <20171024014909.7347-1-nikolas@gnu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nik Nyby <nikolas@gnu.org> wrote:

> In _rtl8821ae_dbi_write(), wrtie_addr should be write_addr.
> 
> Signed-off-by: Nik Nyby <nikolas@gnu.org>

Patch applied to wireless-drivers-next.git, thanks.

62689167261d rtlwifi: rtl8821ae: Fix typo in variable name

-- 
https://patchwork.kernel.org/patch/10023407/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
