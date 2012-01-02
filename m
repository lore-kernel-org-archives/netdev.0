From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix for nfacct infrastructure in net-next
Date: Sun, 01 Jan 2012 23:42:20 -0500 (EST)
Message-ID: <20120101.234220.1974401426311633045.davem@davemloft.net>
References: <20120101162358.GA21795@1984>
	<20120101.180229.1338519415596129407.davem@davemloft.net>
	<20120102010415.GA23310@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120102010415.GA23310@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 2 Jan 2012 02:04:15 +0100

> This is not intended for current 3.2-rc7. This is a fix for something
> that is in your net-next tree (upcoming 3.3).

I think this is the communication problem we had, I thought this
was a netfilter bug fix that was already in net-next that you wanted
me to include in net.

Now that I understand the situation I've pulled the fix into net-next,
thanks.
