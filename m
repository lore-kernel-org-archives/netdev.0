From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] xen-netback: guest rx side refactor
Date: Thu, 06 Oct 2016 20:38:52 -0400 (EDT)
Message-ID: <20161006.203852.1878781609807456985.davem@davemloft.net>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753266AbcJGAiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 20:38:55 -0400
In-Reply-To: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Tue, 4 Oct 2016 10:29:11 +0100

> This series refactors the guest rx side of xen-netback:
> 
> - The code is moved into its own source module.
> 
> - The prefix variant of GSO handling is retired (since it is no longer
>   in common use, and alternatives exist).
> 
> - The code is then simplified and modifications made to improve
>   performance.
> 
> v2:
> - Rebased onto refreshed net-next

Series applied, thanks.
