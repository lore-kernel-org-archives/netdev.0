From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [1/2] ath10k: remove unused <linux/semaphore.h>
Date: Fri, 8 Jul 2016 08:44:28 +0200
Message-ID: <71b9d76a0a914d21adf71ca7493fa637@euamsexm01a.eu.qualcomm.com>
References: <20160621114539.15313-1-chaehyun.lim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	Chaehyun Lim <chaehyun.lim@gmail.com>,
	<ath10k@lists.infradead.org>
To: Chaehyun Lim <chaehyun.lim@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:5652 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbcGHGog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 02:44:36 -0400
In-Reply-To: <20160621114539.15313-1-chaehyun.lim@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chaehyun Lim <chaehyun.lim@gmail.com> wrote:
> <linux/semaphore.h> is not used anymore, so just remove it.
> 
> Signed-off-by: Chaehyun Lim <chaehyun.lim@gmail.com>

Thanks, 1 patch applied to ath-next branch of ath.git:

a3dadad73324 ath10k: remove unused <linux/semaphore.h>

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9190357/
