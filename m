From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH - net-2.6.24 1/2] Introduce and use print_ip
Date: Thu, 20 Sep 2007 16:16:54 +0200
Message-ID: <20070920141654.GE15613@postel.suug.ch>
References: <1190271217.26101.93.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55931 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbXITOQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 10:16:34 -0400
Content-Disposition: inline
In-Reply-To: <1190271217.26101.93.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Joe Perches <joe@perches.com> 2007-09-19 23:53
> This removes the uses of NIPQUAD and HIPQUAD in
> drivers/net and net
> 
> IPV4 Use:
> 
> 	DECLARE_IP_BUF(ipbuf);
> 	__be32 addr;
> 	print_ip(ipbuf, addr)
> 
> Signed-off-by:  Joe Perches <joe@perches.com>
> 
> please pull from:
> git pull http://repo.or.cz/r/linux-2.6/trivial-mods.git print_ipv4

Including a patch for review would be helpful.
