From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/7] netvsc: minor fixes and optimization
Date: Sat, 29 Jul 2017 15:26:44 -0700 (PDT)
Message-ID: <20170729.152644.1642770487758929777.davem@davemloft.net>
References: <20170728155947.10062-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdG2W0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 18:26:45 -0400
In-Reply-To: <20170728155947.10062-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 28 Jul 2017 08:59:40 -0700

> This is a subset of earlier submission with a few more fixes
> found during testing. The are two small optimizations, one is to
> better manage the receive completion ring, and the other is removing
> one unneeded level of indirection.
> 
> Will submit the improved VF support and buffer sizing in a later
> patch so they get more review.

Series applied, thanks Stephen.
