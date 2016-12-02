From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/rtnetlink: fix attribute name in nlmsg_size()
 comments
Date: Fri, 02 Dec 2016 10:35:19 -0500 (EST)
Message-ID: <20161202.103519.1696406825169462073.davem@davemloft.net>
References: <20161130133037.14315-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932309AbcLBPf2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 10:35:28 -0500
In-Reply-To: <20161130133037.14315-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed, 30 Nov 2016 14:30:37 +0100

> Use the correct attribute constant names IFLA_GSO_MAX_{SEGS,SIZE}
> instead of IFLA_MAX_GSO_{SEGS,SIZE} for the comments int nlmsg_size().
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
