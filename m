From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix missing kernel-doc notation
Date: Sun, 22 Nov 2009 20:43:52 -0800 (PST)
Message-ID: <20091122.204352.193610958.davem@davemloft.net>
References: <1258877946.4495.52.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jaswinder@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756384AbZKWEnf@vger.kernel.org>
In-Reply-To: <1258877946.4495.52.camel@ht.satnam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Sun, 22 Nov 2009 13:49:06 +0530

> 
> Fix the following htmldocs warning:
> 
>   Warning(net/core/dev.c:5378): bad line:
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

Applied to net-next-2.6

Please make it explicit what tree the patch is against and intended
to be applied to.  I had to try net-2.6 and net-next-2.6 by hand to
figure out where this patch was targeted.

Thanks.
