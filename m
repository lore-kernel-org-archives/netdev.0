From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] xen-netback: guest rx side refactor
Date: Tue, 04 Oct 2016 00:51:50 -0400 (EDT)
Message-ID: <20161004.005150.162970316361904440.davem@davemloft.net>
References: <1475479872-23717-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54448 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbcJDEvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 00:51:54 -0400
In-Reply-To: <1475479872-23717-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Mon, 3 Oct 2016 08:31:05 +0100

> This series refactors the guest rx side of xen-netback:
> 
> - The code is moved into its own source module.
> 
> - The prefix variant of GSO handling is retired (since it is no longer
>   in common use, and alternatives exist).
> 
> - The code is then simplified and modifications made to improve
>   performance.

This doesn't apply cleanly to net-next, please respin.
