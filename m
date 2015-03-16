From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [2/6] rtlwifi: Clean rtl_evm_db_to_percentage a bit
Date: Mon, 16 Mar 2015 15:58:12 +0000 (UTC)
Message-ID: <20150316155812.CFB66141BB1@smtp.codeaurora.org>
References: <1426104209-6913-3-git-send-email-plaes@plaes.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Priit Laes <plaes@plaes.org>
To: Priit Laes <plaes@plaes.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37450 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935230AbbCPP6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 11:58:13 -0400
In-Reply-To: <1426104209-6913-3-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Signed-off-by: Priit Laes <plaes@plaes.org>

Thanks, 2 patches applied to wireless-drivers-next.git:

54fb66d6fe98 rtlwifi: Clean rtl_evm_db_to_percentage a bit
52f119ddea41 rtlwifi: No need to export rtl_evm_dbm_jaguar anymore

3 patches skipped because of conflicts:

[3/6] rtlwifi: Use common rtl_evm_db_to_percentage
[5/6] rtlwifi: Use common rtl_signal_scale_mapping
[6/6] rtlwifi: Rename rtl_translate_todbm to rtl_signalpower_todbm

And patch 1 dropped due to comments.

Kalle Valo
