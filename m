From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] qed*: Patch series
Date: Mon, 31 Oct 2016 15:52:54 -0400 (EDT)
Message-ID: <20161031.155254.2213369781807264171.davem@davemloft.net>
References: <1477890867-3789-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56984 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945732AbcJaTw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:52:56 -0400
In-Reply-To: <1477890867-3789-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Mon, 31 Oct 2016 07:14:20 +0200

> This series does several things. The bigger changes:
> 
>  - Add new notification APIs [& Defaults] for various fields.
> The series then utilizes some of those qed <-> qede APIs to bass WoL
> support upon.
> 
>  - Change the resource allocation scheme to receive the values from
> management firmware, instead of equally sharing resources between
> functions [that might not need those]. That would, e.g., allow us to
> configure additional filters to network interfaces in presence of
> storage [PCI] functions from same adapter.

Series applied, thanks.
