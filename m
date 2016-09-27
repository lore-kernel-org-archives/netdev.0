From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: Add switch variable to 'switch case not processed'
 messages
Date: Tue, 27 Sep 2016 15:45:33 +0000 (UTC)
Message-ID: <20160927154534.1881C616FE@smtp.codeaurora.org>
References: <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Jean Delvare <jdelvare@suse.de>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42765 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933122AbcI0Ppf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 11:45:35 -0400
In-Reply-To: <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:
> Help along debugging by showing what switch/case variable is not
> being processed in these messages.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Patch applied to wireless-drivers-next.git, thanks.

ad5748893b27 rtlwifi: Add switch variable to 'switch case not processed' messages

-- 
https://patchwork.kernel.org/patch/9348573/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
