From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: Use setup_timer and mod_timer
Date: Wed, 11 Feb 2015 19:40:45 -0800 (PST)
Message-ID: <20150211.194045.834492460059492958.davem@davemloft.net>
References: <20150211102950.GA23755@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-lkml@lebenslange-mailadresse.de, balbi@ti.com,
	justinvanwijngaarden@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150211102950.GA23755@vaishali-Ideapad-Z570>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Wed, 11 Feb 2015 15:59:50 +0530

> This patch introduces the use of functions setup_timer
> and mod_timer.
> 
> This is done using Coccinelle and semantic patch used
> for this as follows:
 ...
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied.
