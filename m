From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv4/netfilter/: small cleanups
Date: Tue, 29 Nov 2005 16:28:30 -0800 (PST)
Message-ID: <20051129.162830.76763512.davem@davemloft.net>
References: <20051123004108.GE3963@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: coreteam@netfilter.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750723AbVK3A3D@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20051123004108.GE3963@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 23 Nov 2005 01:41:08 +0100

> This patch contains the following cleanups:
> - make needlessly global code static
> - ip_conntrack_core.c: ip_conntrack_flush() -> ip_conntrack_flush(void)
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
