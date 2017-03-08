From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wireless/atmel: remove time_t usage
Date: Wed,  8 Mar 2017 15:13:40 +0000 (UTC)
Message-ID: <20170308151340.7FE4E60793@smtp.codeaurora.org>
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
Received: from smtp.codeaurora.org ([198.145.29.96]:46546 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751978AbdCHPNq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 10:13:46 -0500
In-Reply-To: <20170223161445.19200-1-alexandre.belloni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexandre Belloni <alexandre.belloni@free-electrons.com> wrote:
> last_qual never really holds a time. It only holds jiffies. Make it the
> same type as jiffies.
> 
> Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

The title should start with "atmel:", I can fix that during commit.

-- 
https://patchwork.kernel.org/patch/9588521/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
