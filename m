From: David Miller <davem@davemloft.net>
Subject: Re: Kernel oops in 2.6.27-rc1 qdisc.
Date: Wed, 30 Jul 2008 00:04:29 -0700 (PDT)
Message-ID: <20080730.000429.63188454.davem@davemloft.net>
References: <200807291923.22803.steven@springl.ukfsn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: steven@springl.ukfsn.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752560AbYG3HEq@vger.kernel.org>
In-Reply-To: <200807291923.22803.steven@springl.ukfsn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Jan Springl <steven@springl.ukfsn.org>
Date: Tue, 29 Jul 2008 19:23:22 +0100

> Issuing the following command causes a kernel oops:
> 	tc qdisc add dev eth0 handle ffff: ingress
> 
> The problem is recreatable.
> The kernel is 2.6.27-rc1.
> I am using Debian etch.
> 
> The oops is attached.

Thanks for the report, I'll fix this.

Please CC: netdev on networking bug reports in the future, thanks.
