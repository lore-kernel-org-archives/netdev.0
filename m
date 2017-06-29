From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rxrpc: remove unused static variables
Date: Thu, 29 Jun 2017 12:42:40 -0400 (EDT)
Message-ID: <20170629.124240.202378107040464389.davem@davemloft.net>
References: <20170627161818.30346-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, dhowells@redhat.com, netdev@vger.kernel.org
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42518 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751669AbdF2Qmm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 12:42:42 -0400
In-Reply-To: <20170627161818.30346-1-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Tue, 27 Jun 2017 18:18:18 +0200

> The rxrpc_security_methods and rxrpc_security_sem user has been removed
> in 648af7fca159 ("rxrpc: Absorb the rxkad security module"). This was
> noticed by kbuild test robot for the -RT tree but is also true for !RT.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: David Howells <dhowells@redhat.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

David H., are you going to take this into your tree?
