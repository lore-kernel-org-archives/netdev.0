From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] drivers/char/random.c: unexport
 secure_ipv6_port_ephemeral
Date: Sun, 09 Apr 2006 22:29:26 -0700 (PDT)
Message-ID: <20060409.222926.61912446.davem@davemloft.net>
References: <20060409155822.GI8454@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750872AbWDJF3n@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060409155822.GI8454@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 9 Apr 2006 17:58:22 +0200

> This patch removes the unused EXPORT_SYMBOL(secure_ipv6_port_ephemeral).
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
