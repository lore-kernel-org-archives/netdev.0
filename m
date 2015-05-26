From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/5] rtlwifi: Update regulatory database
Date: Tue, 26 May 2015 10:57:08 +0000 (UTC)
Message-ID: <20150526105708.78A79141726@smtp.codeaurora.org>
References: <1431725583-7324-2-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Shao Fu <shaofu@realtek.com>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59679 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbbEZOCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 10:02:49 -0400
In-Reply-To: <1431725583-7324-2-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Shao Fu <shaofu@realtek.com>
> 
> Driver rtlwifi maintains its own regulatory information, The Chrome Autotest
> (https://www.chromium.org/chromium-os/testing/autotest-user-doc)
> showed some errors. This patch adds the necessary information for rtlwifi.
> 
> Signed-off-by: Shao Fu <shaofu@realtek.com>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks, 5 patches applied to wireless-drivers-next.git:

02b5fffbe9e0 rtlwifi: Update regulatory database
852ce7805638 rtlwifi: rtl8188ee: Apply the new regulatory information
5620302484d4 rtlwifi: rtl8192ee: Apply the regulatory changes to driver
b23cd22d3923 rtlwifi: rtl8723be: Update driver for regulatory changes
d10101a60372 rtlwifi: rtl8821ae: Fix problem with regulatory information

Kalle Valo
