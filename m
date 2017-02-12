From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: fix swapped arguments to
 efx_ef10_handle_rx_event_errors
Date: Sat, 11 Feb 2017 21:21:49 -0500 (EST)
Message-ID: <20170211.212149.305873750144107668.davem@davemloft.net>
References: <3d0f460b-b283-4157-33a4-0c30257a1cba@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdBLCVy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 21:21:54 -0500
In-Reply-To: <3d0f460b-b283-4157-33a4-0c30257a1cba@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 10 Feb 2017 17:34:59 +0000

> Fixes: a0ee35414837 ("sfc: process RX event inner checksum flags")
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied.
