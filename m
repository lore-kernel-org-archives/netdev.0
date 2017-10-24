From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: rxrpc: mark expected switch fall-throughs
Date: Tue, 24 Oct 2017 18:27:51 +0900 (KST)
Message-ID: <20171024.182751.1589810689982093148.davem@davemloft.net>
References: <20171019165015.Horde.gFbCP0wQxOy_VCfPCdilo2m@gator4166.hostgator.com>
        <20171019215448.GA20170@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751889AbdJXJ2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:28:51 -0400
In-Reply-To: <20171019215448.GA20170@embeddedor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 19 Oct 2017 16:54:48 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
> This code was tested by compilation only (GCC 7.2.0 was used).
> Please, verify if the actual intention of the code is to fall through.
> 
> Changes in v2:
>  Start every "Fall through" comment with capital 'F'.
>  Put back blank lines.

Applied.
