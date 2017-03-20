From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: atmel: remove time_t usage
Date: Mon, 20 Mar 2017 16:43:37 +0000 (UTC)
Message-ID: <20170320164337.CC0E1601A1@smtp.codeaurora.org>
References: <20170223161445.19200-1-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Simon Kelley <simon@thekelleys.org.uk>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34952 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755737AbdCTQpU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 12:45:20 -0400
In-Reply-To: <20170223161445.19200-1-alexandre.belloni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexandre Belloni <alexandre.belloni@free-electrons.com> wrote:
> last_qual never really holds a time. It only holds jiffies. Make it the
> same type as jiffies.
> 
> Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

Patch applied to wireless-drivers-next.git, thanks.

5c5105666de5 atmel: remove time_t usage

-- 
https://patchwork.kernel.org/patch/9588521/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
