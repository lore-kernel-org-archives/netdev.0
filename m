From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 00:26:01 -0400 (EDT)
Message-ID: <20141015.002601.1719669911383742491.davem@davemloft.net>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	<1413346503.17109.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jiafei.Pan@freescale.com, jkosina@suse.cz, netdev@vger.kernel.org,
	LeoLi@freescale.com, linux-doc@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1413346503.17109.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Oct 2014 21:15:03 -0700

> Take a look at how drivers can 'lock' pages already, and build skb
> sith page frags. It is already there.

+1
