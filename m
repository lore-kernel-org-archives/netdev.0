From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth alignment fix for sh7724 using
 NET_IP_ALIGN V2
Date: Tue, 15 Dec 2009 21:17:09 -0800 (PST)
Message-ID: <20091215.211709.59661976.davem@davemloft.net>
References: <20091215110344.13016.27379.sendpatchset@rxone.opensource.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: magnus.damm@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20091215110344.13016.27379.sendpatchset@rxone.opensource.se>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <magnus.damm@gmail.com>
Date: Tue, 15 Dec 2009 20:03:44 +0900

> From: Magnus Damm <damm@opensource.se>
> 
> Fix sh_eth for sh7724 by adding NET_IP_ALIGN support V2.
> Without this patch the receive data is misaligned.
> 
> Signed-off-by: Magnus Damm <damm@opensource.se>

Applied, thanks.
