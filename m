From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] cleanups and RX path rewrite
Date: Tue, 01 Nov 2016 11:05:21 -0400 (EDT)
Message-ID: <20161101.110521.1800654017998947210.davem@davemloft.net>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751448AbcKAPFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:05:23 -0400
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 31 Oct 2016 20:43:08 +0000

> This series lays groundwork for upcoming XDP support by updating
> the RX path not to pre-allocate sk_buffs.  I start with few
> cleanups, removal of NFP3200-related code being the most significant.
> Patch 7 moves to alloc_frag() and build_skb() APIs.  Again, a number
> of small cleanups follow.  The set ends with adding support for
> different number of RX and TX rings.

Series applied, thank you.
