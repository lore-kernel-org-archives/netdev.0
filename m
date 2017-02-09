From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] sfc: more encap offloads
Date: Thu, 09 Feb 2017 16:48:15 -0500 (EST)
Message-ID: <20170209.164815.725900604860030929.davem@davemloft.net>
References: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51190 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752840AbdBIV5Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:57:16 -0500
In-Reply-To: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 8 Feb 2017 16:49:12 +0000

> This patch series adds support for RX checksum offload of encapsulated packets.
> It also adds support for configuring the hardware's lists of UDP ports used for
> VXLAN and GENEVE encapsulation offloads.  Since changing these lists causes the
> MC to reboot, the driver has been hardened against reboots, which used to be
> considered an exceptional occurrence but are now normal.

Series applied, thanks.
