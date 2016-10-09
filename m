From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] be2net: patch-set
Date: Sun, 09 Oct 2016 09:31:23 -0400 (EDT)
Message-ID: <20161009.093123.2169328494259664121.davem@davemloft.net>
References: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47772 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751401AbcJINcm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 09:32:42 -0400
In-Reply-To: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Date: Sun,  9 Oct 2016 09:58:48 +0530

> The following patch set contains a few bug fixes.
> Please consider applying this to the net-next tree.
> Thanks.
> 
> Patch-1 Obtains proper PF number for BEx chips
> Patch-2 Fixes a FW update issue seen with BEx chips
> Patch-3 Updates copyright string
> Patch-4 Fixes TX stats for TSO packets
> Patch-5 Enables VF link state setting for BE3

Please do not target real bug fixes at net-next, they should
target 'net' instead.

And that's where I have applied this series.

Thanks.
