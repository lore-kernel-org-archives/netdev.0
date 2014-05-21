From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4 V2] atm: idt77252: Remove redundant error check
Date: Wed, 21 May 2014 15:56:55 -0400 (EDT)
Message-ID: <20140521.155655.2246792997958517691.davem@davemloft.net>
References: <1400495212-9150-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: peter.senna@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400495212-9150-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>
Date: Mon, 19 May 2014 12:26:52 +0200

> Remove double checks, convert printk to pr_warn, and move the call to
> pr_warn to the first check. The simplified version of the coccinelle
> semantic patch that find this issue is as follows:
 ...
> Tested by compilation only.
> 
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Applied to net-next, thanks.
