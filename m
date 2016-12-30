From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH][V2] [media] gp8psk: fix spelling mistake: "firmare" -> "firmware"
Date: Fri, 30 Dec 2016 16:35:47 +0200
Message-ID: <87bmvtjxh8.fsf@purkki.adurom.net>
References: <20161229213815.27890-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        linux-media@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41510 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754069AbcL3Of5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 09:35:57 -0500
In-Reply-To: <20161229213815.27890-1-colin.king@canonical.com> (Colin King's
        message of "Thu, 29 Dec 2016 21:38:15 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Colin King <colin.king@canonical.com> writes:

> From: Colin Ian King <colin.king@canonical.com>
>
> Trivial fix to spelling mistake in err message. Also change "don't" to
> "does not".
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/media/usb/dvb-usb/gp8psk.c          | 2 +-
>  drivers/net/wireless/realtek/rtlwifi/core.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

Could you split the rtlwifi part to it's own patch? I can't apply
patches touching media drivers.

-- 
Kalle Valo
