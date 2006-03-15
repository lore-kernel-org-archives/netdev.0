From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [-mm patch] make drivers/net/tg3.c:tg3_request_irq()
Date: Tue, 14 Mar 2006 17:04:48 -0800 (PST)
Message-ID: <20060314.170448.34817198.davem@davemloft.net>
References: <20060312031036.3a382581.akpm@osdl.org>
	<20060313212602.GL13973@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932146AbWCOBE6@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060313212602.GL13973@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Mon, 13 Mar 2006 22:26:02 +0100

> This patch makes the needlessly global function tg3_request_irq() 
> static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
