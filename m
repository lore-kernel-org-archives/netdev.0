From: Bruno Randolf <br1@einfach.org>
Subject: Re: [PATCH] rtlwifi: fix gigantic memleak in rtl_usb
Date: Mon, 7 Dec 2015 16:04:39 +0000
Message-ID: <5665AE17.8010601@einfach.org>
References: <1449424677-3140-1-git-send-email-peter@lekensteyn.nl>
 <5664981C.1040704@lwfinger.net> <20151206213926.GA30777@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Wu <peter@lekensteyn.nl>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151206213926.GA30777@al>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/06/2015 09:39 PM, Peter Wu wrote:
>>> While using the rtl8192cu driver in monitor mode, somehow 5G of memory
>>> was permanently lost (observable via the Available column in `free -m`).
>>>
>>> This issue has existed since the introduction of this driver in v2.6.x,

One more reason to switch to rtl8xxxu as soon as possible...

bruno
