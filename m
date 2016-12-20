From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: sfc: Add Kconfig entry for vendor Solarflare
Date: Tue, 20 Dec 2016 14:20:46 -0500 (EST)
Message-ID: <20161220.142046.673791508635574858.davem@davemloft.net>
References: <20161220133826.1478-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
        ecree@solarflare.com, bkenward@solarflare.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44318 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752793AbcLTTUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 14:20:48 -0500
In-Reply-To: <20161220133826.1478-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 20 Dec 2016 14:38:26 +0100

> Since commit
> 
>   5a6681e22c14 ("sfc: separate out SFC4000 ("Falcon") support into new sfc-falcon driver")
> 
> there are two drivers for Solarflare devices, but both still show up
> directly beneath "Ethernet driver support" in the Kconfig. Follow the
> pattern of other vendors and group them beneath an own vendor Kconfig
> entry for Solarflare.
> 
> Cc: Edward Cree <ecree@solarflare.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
