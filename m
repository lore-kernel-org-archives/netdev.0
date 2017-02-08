From: David Miller <davem@davemloft.net>
Subject: Re: gro_cells: move to net/core/gro_cells.c
Date: Wed, 08 Feb 2017 14:38:44 -0500 (EST)
Message-ID: <20170208.143844.410871248292652471.davem@davemloft.net>
References: <1486510635.7793.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdBHUQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:16:00 -0500
In-Reply-To: <1486510635.7793.72.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Feb 2017 15:37:15 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We have many gro cells users, so lets move the code to avoid
> duplication.
> 
> This creates a CONFIG_GRO_CELLS option.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to.... net-next... thanks Eric :)
