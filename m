From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove NO_IRQ from powerpc-only network drivers
Date: Tue, 13 Sep 2016 11:41:23 -0400 (EDT)
Message-ID: <20160913.114123.130707105572714908.davem@davemloft.net>
References: <1473501545-10134-1-git-send-email-mpe@ellerman.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@ozlabs.org, arnd@arndb.de
To: mpe@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40190 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752710AbcIMPlX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:41:23 -0400
In-Reply-To: <1473501545-10134-1-git-send-email-mpe@ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Ellerman <mpe@ellerman.id.au>
Date: Sat, 10 Sep 2016 19:59:05 +1000

> We'd like to eventually remove NO_IRQ on powerpc, so remove usages of it
> from powerpc-only drivers.
> 
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>

Applied to net-next, thanks.
