From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] siphash: add cryptographically secure PRF
Date: Fri, 06 Jan 2017 14:57:37 -0500 (EST)
Message-ID: <20170106.145737.1436197697379516563.davem@davemloft.net>
References: <20170106183716.5567-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jeanphilippe.aumasson@gmail.com, torvalds@linux-foundation.org,
        ebiggers3@gmail.com, David.Laight@aculab.com,
        eric.dumazet@gmail.com
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161126AbdAFT5l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 14:57:41 -0500
In-Reply-To: <20170106183716.5567-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Proper patch series submissions require a header "[PATCH 0/N] ..." posting
explaining at a high level, what the series is doing, how it is doing it,
and why it is doing it that way.
