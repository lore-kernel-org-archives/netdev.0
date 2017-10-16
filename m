From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dccp: mark expected switch fall-throughs
Date: Mon, 16 Oct 2017 21:15:47 +0100 (WEST)
Message-ID: <20171016.211547.1957282103530139102.davem@davemloft.net>
References: <20171015182210.GA13849@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34598 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753285AbdJPUPt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:15:49 -0400
In-Reply-To: <20171015182210.GA13849@embeddedor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Sun, 15 Oct 2017 13:22:10 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Notice that for options.c file, I placed the "fall through" comment
> on its own line, which is what GCC is expecting to find.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied to net-next.
