From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [RESEND] ssb: Fix Sparse error in main
Date: Thu, 29 Jan 2015 08:18:45 +0000 (UTC)
Message-ID: <20150129081845.D4BA813FE12@smtp.codeaurora.org>
References: <1422424187-19059-1-git-send-email-pramod.gurav@smartplayin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, Michael Buesch <m@bues.ch>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Pramod Gurav <pramod.gurav@smartplayin.com>
To: Pramod Gurav <pramod.gurav@smartplayin.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422424187-19059-1-git-send-email-pramod.gurav@smartplayin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> This change fixes below sparse error:
> drivers/ssb/main.c:94:16: warning: symbol 'ssb_sdio_func_to_bus'
> was not declared. Should it be static?
> 
> Acked-by: Michael Buesch <m@bues.ch>
> Signed-off-by: Pramod Gurav <pramod.gurav@smartplayin.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
