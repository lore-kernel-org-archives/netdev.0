From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: propagate error if IRQ request fails in mwifiex_sdio_of()
Date: Sat,  3 Sep 2016 10:35:20 +0000 (UTC)
Message-ID: <20160903103520.3E62B62019@smtp.codeaurora.org>
References: <1471529868-13669-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Amitkumar Karwar <akarwar@marvell.com>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59330 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753163AbcICKha (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 06:37:30 -0400
In-Reply-To: <1471529868-13669-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Javier Martinez Canillas <javier@osg.samsung.com> wrote:
> If request_irq() fails in mwifiex_sdio_probe_of(), only an error message
> is printed but the actual error is not propagated to the caller function.
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

What's the conclusion with this patch? Should I drop it or take it?

(The discussion is available from the patchwork link in the signature.)

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9288169/
