From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2 2/2] tc/m_tunnel_key: Add dest UDP port to
 tunnel key action
Date: Thu, 15 Dec 2016 14:53:13 +0100
Message-ID: <20161215135312.GB7104@penelope.horms.nl>
References: <1481616467-769-1-git-send-email-hadarh@mellanox.com>
 <1481616467-769-3-git-send-email-hadarh@mellanox.com>
 <20161215130335.GA30716@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Amir Vadai <amirva@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f175.google.com ([209.85.210.175]:35657 "EHLO
        mail-wj0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755007AbcLONxz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 08:53:55 -0500
Received: by mail-wj0-f175.google.com with SMTP id v7so66072830wjy.2
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 05:53:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161215130335.GA30716@penelope.horms.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 02:03:36PM +0100, Simon Horman wrote:
> On Tue, Dec 13, 2016 at 10:07:47AM +0200, Hadar Hen Zion wrote:
> > Enhance tunnel key action parameters by adding destination UDP port.
> > 
> > Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> > Reviewed-by: Roi Dayan <roid@mellanox.com>
> 
> Hi,
> 
> this looks good to me but could you also update tc/m_tunnel_key.c:usage(); ?

It seems that I was a bit hasty here as I now see that Stephen has
indicated that he has applied this series. I also notice that
patch 1/2 of this series also misses updating usage(). Let me know
if sending some follow-up patches is the best way forwards.
