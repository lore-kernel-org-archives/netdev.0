From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/9] net: use core MTU range checking
 everywhere
Date: Thu, 20 Oct 2016 14:53:44 -0400 (EDT)
Message-ID: <20161020.145344.2118760258546112762.davem@davemloft.net>
References: <20161019023333.15760-1-jarod@redhat.com>
        <20161020175524.6184-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933602AbcJTSxq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:53:46 -0400
In-Reply-To: <20161020175524.6184-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>
Date: Thu, 20 Oct 2016 13:55:15 -0400

> This stack of patches should get absolutely everything in the kernel
> converted from doing their own MTU range checking to the core MTU range
> checking. This second spin includes alterations to hopefully fix all
> concerns raised with the first, as well as including some additional
> changes to drivers and infrastructure where I completely missed necessary
> updates.
> 
> These have all been built through the 0-day build infrastructure via the
> (rebasing) master branch at https://github.com/jarodwilson/linux-muck, which
> at the time of the most recent compile across 147 configs, was based on
> net-next at commit 7b1536ef0aa0.

Series applied, hopefully this gets most of the fallout.

Thanks Jarod.
