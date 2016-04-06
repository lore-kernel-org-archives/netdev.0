From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: sdio: remove unused variable retry_limit
Date: Wed,  6 Apr 2016 18:43:03 +0000 (UTC)
Message-ID: <20160406184303.18F6961608@smtp.codeaurora.org>
References: <1458495292-17701-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Kosuke Tatsukawa <tatsu@ab.jp.nec.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458495292-17701-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Colin Ian King <colin.king@canonical.com>
> 
> retry_limit has never been used during the life of this driver, so
> we may as well remove it as it is redundant.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
