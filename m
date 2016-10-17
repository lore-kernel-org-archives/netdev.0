From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] ipv6: sr: add code base for control plane support
 of SR-IPv6
Date: Mon, 17 Oct 2016 11:21:24 -0400 (EDT)
Message-ID: <20161017.112124.1770727208696766155.davem@davemloft.net>
References: <1476715350-18983-3-git-send-email-david.lebrun@uclouvain.be>
        <20161017.110055.762862023679772858.davem@davemloft.net>
        <5804E8DE.20200@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933143AbcJQPV0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:21:26 -0400
In-Reply-To: <5804E8DE.20200@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Mon, 17 Oct 2016 17:06:06 +0200

> The mutex is not taken, just initialized. Unless mutex_init takes the
> lock, which would be quite strange ?

My bad, I misread the code.
