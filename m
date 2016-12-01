From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] sfc: defalconisation fixups
Date: Thu, 01 Dec 2016 15:39:59 -0500 (EST)
Message-ID: <20161201.153959.1963421484251790288.davem@davemloft.net>
References: <c52a0276-e379-7841-8d10-d5a834b81c4e@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, bkenward@solarflare.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43940 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752480AbcLAUkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:40:02 -0500
In-Reply-To: <c52a0276-e379-7841-8d10-d5a834b81c4e@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 1 Dec 2016 16:59:13 +0000

> A bug fix, the Kconfig change, and cleaning up a bit more unused code.
> 
> Edward Cree (3):
>   sfc: fix debug message format string in efx_farch_handle_rx_not_ok
>   sfc: don't select SFC_FALCON
>   sfc: remove RESET_TYPE_RX_RECOVERY

Series applied, thank you.
