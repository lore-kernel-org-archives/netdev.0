From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] Couple of BPF refcount fixes for mlx5
Date: Mon, 21 Nov 2016 11:26:17 -0500 (EST)
Message-ID: <20161121.112617.1629076933006050214.davem@davemloft.net>
References: <cover.1479514784.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        zhiyisun@gmail.com, ranas@mellanox.com, saeedm@mellanox.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52940 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754365AbcKUQ0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 11:26:19 -0500
In-Reply-To: <cover.1479514784.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 19 Nov 2016 01:44:59 +0100

> Various mlx5 bugs on eBPF refcount handling found during review.
> Last patch in series adds a __must_check to BPF helpers to make
> sure we won't run into it again w/o compiler complaining first.

Series applied, thanks Daniel.
