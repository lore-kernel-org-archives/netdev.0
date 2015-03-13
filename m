From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [next] ath9k: make ath_frame_info fit into
 reduced-sizerate_driver_data
Date: Fri, 13 Mar 2015 14:09:20 +0000 (UTC)
Message-ID: <20150313140920.50074141606@smtp.codeaurora.org>
References: <1425998662-28401-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, ath9k-devel@qca.qualcomm.com,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51364 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579AbbCMOJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:09:21 -0400
In-Reply-To: <1425998662-28401-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> pre-requisite to shrink size of ieee80211_tx_info which in turn is
> needed to shrink skb->cb to 40 bytes again.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
