From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] qed*: PTP enhancements.
Date: Thu, 27 Apr 2017 16:52:31 -0400 (EDT)
Message-ID: <20170427.165231.727167942325735113.davem@davemloft.net>
References: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
        Yuval.Mintz@cavium.com
To: sudarsana.kalluru@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967179AbdD0Uwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 16:52:33 -0400
In-Reply-To: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Date: Wed, 26 Apr 2017 09:00:48 -0700

> From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
> 
> The patch series contains set of enhancements for qed/qede ptp
> implementation.
> Patches (1)-(3) adds resource locking implementation to allow 
> PTP functionality only on the first detected ethernet PF of the port.
> The change is required as the adapter currently supports only one
> instance of the PTP client on a given port.
> Patch (4) removes the un-needed header file.
> Patch (5) moves the ptt-lock get/release logic to the ptp specific
> code.
> 
> Please consider applying this series to "net-next" branch.

Series applied, thanks!
