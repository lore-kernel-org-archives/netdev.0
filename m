From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sfc: small MCDI cleanups
Date: Sat, 01 Jul 2017 15:25:01 -0700 (PDT)
Message-ID: <20170701.152501.1208714288828292706.davem@davemloft.net>
References: <fd53588b-c163-4c82-a8f2-c0b08ccb95b5@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34598 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751611AbdGAWZH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 18:25:07 -0400
In-Reply-To: <fd53588b-c163-4c82-a8f2-c0b08ccb95b5@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 30 Jun 2017 15:52:58 +0100

> Giving the full MCDI event rather than just the code can aid in
>  debugging.  While fixing this I noticed an outdated comment.

Series applied, thanks Edward.
