From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] liquidio: store the L4 hash of rx packets
 in skb
Date: Tue, 10 Jan 2017 14:23:02 -0500 (EST)
Message-ID: <20170110.142302.1520724578882136544.davem@davemloft.net>
References: <20170109224240.GA10166@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        eric.dumazet@gmail.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51730 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765761AbdAJTXO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 14:23:14 -0500
In-Reply-To: <20170109224240.GA10166@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 9 Jan 2017 14:42:40 -0800

> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> Store the L4 hash of received packets in the skb; the hash is computed in
> the NIC firmware.
> 
> Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied, thanks.
