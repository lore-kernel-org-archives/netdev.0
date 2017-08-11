From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: rx/tx queue cleanup
Date: Fri, 11 Aug 2017 13:55:07 -0700 (PDT)
Message-ID: <20170811.135507.610526383173368042.davem@davemloft.net>
References: <20170809190708.GA1122@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753724AbdHKUzI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:55:08 -0400
In-Reply-To: <20170809190708.GA1122@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 9 Aug 2017 12:07:08 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> When deleting a queue, clear its corresponding bit in the qmask, vfree its
> memory, clear out the pointer that's pointing to it, and decrement the
> queue count.
> 
> Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
> Signed-off-by: Felix Manlunas <fmanlunas@cavium.com>

Applied, thanks.
