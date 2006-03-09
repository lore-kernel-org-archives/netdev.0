From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] tg3.c:tg3_bus_string(): remove dead code
Date: Thu, 09 Mar 2006 15:09:45 -0800 (PST)
Message-ID: <20060309.150945.44837916.davem@davemloft.net>
References: <20060309230650.GJ21864@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750834AbWCIXKA@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060309230650.GJ21864@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 10 Mar 2006 00:06:50 +0100

> The Coverity checker spotted this dead code (note that (clock_ctrl == 7) 
> is already handled above).
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
