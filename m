From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/4]: Allow head adjustment in XDP prog
Date: Thu, 08 Dec 2016 14:25:53 -0500 (EST)
Message-ID: <20161208.142553.886534768162867941.davem@davemloft.net>
References: <1481154794-2311034-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, bblanco@plumgrid.com,
        daniel@iogearbox.net, kubakici@wp.pl, brouer@redhat.com,
        john.fastabend@gmail.com, saeedm@mellanox.com, tariqt@mellanox.com,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37342 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbcLHTZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:25:56 -0500
In-Reply-To: <1481154794-2311034-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 7 Dec 2016 15:53:10 -0800

> This series adds a helper to allow head adjusting in XDP prog.  mlx4
> driver has been modified to support this feature.  An example is written
> to encapsulate a packet with an IPv4/v6 header and then XDP_TX it
> out.

Series applied.
