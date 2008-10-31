From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] net: delete excess kernel-doc notation
Date: Thu, 30 Oct 2008 23:54:44 -0700 (PDT)
Message-ID: <20081030.235444.72251677.davem@davemloft.net>
References: <20081029223458.d5295690.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751960AbYJaGzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 02:55:09 -0400
In-Reply-To: <20081029223458.d5295690.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 29 Oct 2008 22:34:58 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Remove excess kernel-doc function parameters from networking header
> & driver files:
> 
> Warning(include/net/sock.h:946): Excess function parameter or struct member 'sk' description in 'sk_filter_release'
> Warning(include/linux/netdevice.h:1545): Excess function parameter or struct member 'cpu' description in 'netif_tx_lock'
> Warning(drivers/net/wan/z85230.c:712): Excess function parameter or struct member 'regs' description in 'z8530_interrupt'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
