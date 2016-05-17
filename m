From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 0/7] fix typo
Date: Tue, 17 May 2016 18:07:37 +0300
Message-ID: <874m9wpvt2.fsf@purkki.adurom.net>
References: <1463495926-13728-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-media@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org,
	devel@driverdev.osuosl.org, pmchba@pmcs.com
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48374 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbcEQPHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 11:07:43 -0400
In-Reply-To: <1463495926-13728-1-git-send-email-Julia.Lawall@lip6.fr> (Julia
	Lawall's message of "Tue, 17 May 2016 16:38:39 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia Lawall <Julia.Lawall@lip6.fr> writes:

> firmare -> firmware
>
> ---
>
>  drivers/media/dvb-frontends/mn88473.c       |    2 +-
>  drivers/net/wireless/ath/ath6kl/core.h      |    2 +-
>  drivers/net/wireless/marvell/mwifiex/pcie.c |    2 +-

It would be good to know in advance what tree you are planning to submit
these for. For example, should I take ath6kl and mwifiex patches or
someone else?

-- 
Kalle Valo
