From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 5/5] net: l2tp: fix negative assignment to
 unsigned int
Date: Wed, 09 Nov 2016 18:56:50 -0500 (EST)
Message-ID: <20161109.185650.2019509498057617104.davem@davemloft.net>
References: <20161107203928.30111-1-asbjorn@asbjorn.st>
        <20161107203928.30111-5-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: asbjorn@asbjorn.st
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44912 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754894AbcKIX4w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 18:56:52 -0500
In-Reply-To: <20161107203928.30111-5-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Date: Mon,  7 Nov 2016 20:39:28 +0000

> recv_seq, send_seq and lns_mode mode are all defined as
> unsigned int foo:1;
> 
> Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>

Applied.
