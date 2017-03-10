From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] bnxt_en: Misc. small fixes.
Date: Thu, 09 Mar 2017 17:38:48 -0800 (PST)
Message-ID: <20170309.173848.2110997212811315730.davem@davemloft.net>
References: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47592 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdCJBkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 20:40:18 -0500
In-Reply-To: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Wed,  8 Mar 2017 18:44:31 -0500

> Fixes include moving the initial function reset, notifying the RDMA driver
> during tx timeout, setting dcbx_cap properly depending on whether the
> firmware agent is running or not, and an autoneg related improvement. 

Series applied, thanks Michael.
