From: David Miller <davem@davemloft.net>
Subject: Re: [patch 8/8] RPC: Remove Makefile reference to obsolete RXRPC
 config variable
Date: Mon, 09 Jul 2007 13:21:05 -0700 (PDT)
Message-ID: <20070709.132105.32346558.davem@davemloft.net>
References: <200707091851.l69IpEIo001746@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rpjday@mindspring.com,
	bfields@fieldses.org, trond.myklebust@fys.uio.no
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48434
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754044AbXGIUUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:20:43 -0400
In-Reply-To: <200707091851.l69IpEIo001746@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 09 Jul 2007 11:51:14 -0700

> From: "Robert P. J. Day" <rpjday@mindspring.com>
> 
> Since there is no Kconfig variable RXRPC anywhere in the tree, and the
> variable AF_RXRPC performs exactly the same function, remove the reference
> to CONFIG_RXRPC from net/Makefile.
> 
> Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
> Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
