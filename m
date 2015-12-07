From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] rtlwifi: fix gigantic memleak in rtl_usb
Date: Mon, 07 Dec 2015 17:11:03 +0200
Message-ID: <87k2oqcn08.fsf@kamboji.qca.qualcomm.com>
References: <1449424677-3140-1-git-send-email-peter@lekensteyn.nl>
	<5664981C.1040704@lwfinger.net> <20151206213926.GA30777@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Wu <peter@lekensteyn.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151206213926.GA30777@al> (Peter Wu's message of "Sun, 6 Dec
	2015 22:39:26 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Wu <peter@lekensteyn.nl> writes:

> Originally I had the Cc: stable line added, but the SubmittingPatches
> document seems to discourage that for networking. Added it again.

Yeah, stable wireless patches are handled differently from rest of the
networking subsystem. It would be great if somebody could update the
documentation.

-- 
Kalle Valo
