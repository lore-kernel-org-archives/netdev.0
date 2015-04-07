From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: ath9k_htc: check seq number instead of cmd id for timeout
Date: Tue,  7 Apr 2015 17:08:20 +0000 (UTC)
Message-ID: <20150407170820.D2660140CC7@smtp.codeaurora.org>
References: <1426235558-13787-1-git-send-email-fred.chou.nd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ath9k-devel@qca.qualcomm.com, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Fred Chou <fred.chou.nd@gmail.com>
To: fred.chou.nd@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:32831 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbDGRIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 13:08:21 -0400
In-Reply-To: <1426235558-13787-1-git-send-email-fred.chou.nd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Fred Chou <fred.chou.nd@gmail.com>
> 
> As the driver may send multiple wmi commands with identical cmd id,
> it is more robust to check seq number for timeout instead.
> 
> Signed-off-by: Fred Chou <fred.chou.nd@gmail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
