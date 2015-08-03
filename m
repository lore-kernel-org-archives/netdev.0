From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [-4.2] rtlwifi: rtl8723be: Add module parameter for MSI interrupts
Date: Mon,  3 Aug 2015 08:26:55 +0000 (UTC)
Message-ID: <20150803082655.DBE83140035@smtp.codeaurora.org>
References: <1438539853-29619-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42244 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbbHCI04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 04:26:56 -0400
In-Reply-To: <1438539853-29619-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The driver code allows for the disabling of MSI interrupts; however the
> module_parm line was missed and the option fails to show with modinfo.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org> [3.15+]

Thanks, applied to wireless-drivers.git.

Kalle Valo
