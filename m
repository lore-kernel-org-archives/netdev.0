From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lwtunnel: Handle lwtunnel_fill_encap failure
Date: Thu, 12 Jan 2017 15:12:26 -0500 (EST)
Message-ID: <20170112.151226.1053692744330351041.davem@davemloft.net>
References: <1484173794-7777-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750868AbdALUM2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:12:28 -0500
In-Reply-To: <1484173794-7777-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 11 Jan 2017 14:29:54 -0800

> Handle failure in lwtunnel_fill_encap adding attributes to skb.
> 
> Fixes: 571e722676fe ("ipv4: support for fib route lwtunnel encap attributes")
> Fixes: 19e42e451506 ("ipv6: support for fib route lwtunnel encap attributes")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks David.
