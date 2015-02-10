From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [V2, for, 3.19,
 1/7] rtlwifi: Remove logging statement that is no longer needed
Date: Tue, 10 Feb 2015 14:10:06 +0000 (UTC)
Message-ID: <20150210141006.3A232140EB6@smtp.codeaurora.org>
References: <1421773286-1039-2-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1421773286-1039-2-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> In commit e9538cf4f907 ("rtlwifi: Fix error when accessing unmapped memory
> in skb"), a printk was included to indicate that the condition had been
> reached. There is now enough evidence from other users that the fix is
> working. That logging statement can now be removed.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org> [V3.18]

Thanks, applied to wireless-drivers.git.

Kalle Valo
