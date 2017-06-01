From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: simplify the code around ra_list
Date: Thu,  1 Jun 2017 09:50:59 +0000 (UTC)
Message-ID: <20170601095059.D42C86077A@smtp.codeaurora.org>
References: <1495762909-46795-1-git-send-email-shawn.lin@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        Xinming Hu <huxm@marvell.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Shawn Lin <shawn.lin@rock-chips.com>
To: Shawn Lin <shawn.lin@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36980 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751346AbdFAJvT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 05:51:19 -0400
In-Reply-To: <1495762909-46795-1-git-send-email-shawn.lin@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shawn Lin <shawn.lin@rock-chips.com> wrote:

> We don't need to check if the list is empty separately
> as we could use list_first_entry_or_null to cover it.
> 
> Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>
> Reviewed-by: Brian Norris <briannorris@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

01926202b34b mwifiex: simplify the code around ra_list

-- 
https://patchwork.kernel.org/patch/9749573/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
