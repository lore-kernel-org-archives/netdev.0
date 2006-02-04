From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [-mm patch] net/ipv4/fib_rules.c: make struct fib_rules static
 again
Date: Sat, 04 Feb 2006 15:51:45 -0800 (PST)
Message-ID: <20060204.155145.127399521.davem@davemloft.net>
References: <20060203000704.3964a39f.akpm@osdl.org>
	<20060203210248.GK4408@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, robert.olsson@its.uu.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932594AbWBDXwO@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060203210248.GK4408@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 3 Feb 2006 22:02:48 +0100

> struct fib_rules became global for no good reason.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
