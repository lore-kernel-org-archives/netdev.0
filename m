From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] TI CPSW Cleanup
Date: Wed, 14 May 2014 00:47:58 -0400 (EDT)
Message-ID: <20140514.004758.1002719194974082826.davem@davemloft.net>
References: <1399870281-27200-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mugunthanvnm@ti.com, balbi@ti.com, zonque@gmail.com,
	mpa@pengutronix.de, tklauser@distanz.ch
To: george.cherian@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399870281-27200-1-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Cherian <george.cherian@ti.com>
Date: Mon, 12 May 2014 10:21:18 +0530

> This series does some minimal cleanups.
> 	-Conversion of pr_*() to dev_*()
> 	-Convert kzalloc to devm_kzalloc.

Series applied to net-next, thanks.
