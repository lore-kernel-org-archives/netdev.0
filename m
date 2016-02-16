From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] ravb: fix the fallout of R-Car gen3 gPTP support
Date: Tue, 16 Feb 2016 14:53:19 -0500 (EST)
Message-ID: <20160216.145319.1918944273067707762.davem@davemloft.net>
References: <15000430.RmSAhz5Ejy@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <15000430.RmSAhz5Ejy@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 06 Feb 2016 17:45:37 +0300

>    Here's a set of 2 patches against DaveM's 'net.git' repo fixing up the
> incomplete commit f5d7837f96e5 ("ravb: ptp: Add CONFIG mode support").
> I'm proposing these as fixes but they can be merged as cleanups as well...
> 
> [1/2] ravb: kill duplicate setting of CCC.CSEL
> [2/2] ravb: skip gPTP start/stop on R-Car gen3

Series applied, thanks Sergei.
