From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] soreuseport: do not export reuseport_add_sock()
Date: Tue, 18 Oct 2016 14:18:46 -0400 (EDT)
Message-ID: <20161018.141846.2143723397593988907.davem@davemloft.net>
References: <1476739368.5650.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45014 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034293AbcJRSSs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:18:48 -0400
In-Reply-To: <1476739368.5650.60.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 17 Oct 2016 14:22:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> reuseport_add_sock() is not used from a module,
> no need to export it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
