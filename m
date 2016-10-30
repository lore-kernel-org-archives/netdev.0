From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] mlx4 XDP TX refactor
Date: Sun, 30 Oct 2016 12:44:40 -0400 (EDT)
Message-ID: <20161030.124440.1962738096545317259.davem@davemloft.net>
References: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
        <0773c58c-293d-38be-9844-e8f92d135aec@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tariqt@mellanox.com, netdev@vger.kernel.org, eranbe@mellanox.com
To: ttoukan.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33290 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932604AbcJ3Qoo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 12:44:44 -0400
In-Reply-To: <0773c58c-293d-38be-9844-e8f92d135aec@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <ttoukan.linux@gmail.com>
Date: Sun, 30 Oct 2016 18:21:26 +0200

> Hi Dave,
> 
> This series makes Brenden's fix unneeded:
> 958b3d396d7f ("net/mlx4_en: fixup xdp tx irq to match rx")
> 
> The fix got into net, but yet to be in net-next.
> 
> Should I wait with this series and send a re-spin, with a revert of
> the fix, once it gets into net-next?

I'm working on merging net into net-next right now, once that is
pushed out you can respin.
