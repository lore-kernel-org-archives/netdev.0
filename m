From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [2/3] brcmfmac: dhd_sdio.c: use existing atomic_or primitive
Date: Thu, 13 Aug 2015 12:30:32 +0000 (UTC)
Message-ID: <20150813123032.7D664140538@smtp.codeaurora.org>
References: <1436429599-10762-3-git-send-email-vgupta@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arch@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"Hante Meuleman" <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1436429599-10762-3-git-send-email-vgupta@synopsys.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> There's already a generic implementation so use that instead.

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
