From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: fix unaligned memory access in tcp_sack
Date: Tue, 24 Mar 2009 16:39:05 -0700 (PDT)
Message-ID: <20090324.163905.31868597.davem@davemloft.net>
References: <878wmx3pfk.fsf@netris.org>
	<20090322.211730.224794112.davem@davemloft.net>
	<49C78518.2010106@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mhw@netris.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49C78518.2010106@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 23 Mar 2009 13:48:24 +0100

> Looks good to me. Dave, please apply directly or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Pulled, thanks Patrick.
