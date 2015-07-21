From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: rtl8821ae: Fix an expression that is always false
Date: Tue, 21 Jul 2015 14:59:08 +0000 (UTC)
Message-ID: <20150721145908.9F8EC141A64@smtp.codeaurora.org>
References: <1436368730-636-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	David Binderman <dcb314@hotmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1436368730-636-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> In routine _rtl8821ae_set_media_status(), an incorrect mask results in a test
> for AP status to always be false. Similar bugs were fixed in rtl8192cu and
> rtl8192de, but this instance was missed at that time.
> 
> Reported-by: David Binderman <dcb314@hotmail.com>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org> [3.18+]
> Cc: David Binderman <dcb314@hotmail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
