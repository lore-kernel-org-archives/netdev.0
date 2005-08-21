From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [-mm patch] net/core/sysctl_net_core.c: fix PROC_FS=n compile
Date: Sat, 20 Aug 2005 17:14:46 -0700 (PDT)
Message-ID: <20050820.171446.105447223.davem@davemloft.net>
References: <20050819043331.7bc1f9a9.akpm@osdl.org>
	<20050820190309.GB3615@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750736AbVHUAOu@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20050820190309.GB3615@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 20 Aug 2005 21:03:09 +0200

> This breaks the compilation with CONFIG_PROC_FS=n:
 ..
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
