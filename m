From: David Miller <davem@davemloft.net>
Subject: Re: [PATH net] tcp: do not export tcp_peer_is_proven()
Date: Mon, 09 Jan 2017 16:39:09 -0500 (EST)
Message-ID: <20170109.163909.1893835645194989829.davem@davemloft.net>
References: <1483980692.5846.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51792 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937110AbdAIVjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:39:10 -0500
In-Reply-To: <1483980692.5846.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Jan 2017 08:51:32 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 1fb6f159fd21 ("tcp: add tcp_conn_request"),
> tcp_peer_is_proven() no longer needs to be exported.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
