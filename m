From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: ethoc: Misc improvements
Date: Mon, 05 Dec 2016 15:30:25 -0500 (EST)
Message-ID: <20161205.153025.2001419420007630193.davem@davemloft.net>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, tklauser@distanz.ch,
        thierry.reding@gmail.com, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbcLEUam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 15:30:42 -0500
In-Reply-To: <20161204204030.9853-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun,  4 Dec 2016 12:40:27 -0800

> This patch series fixes/improves a few things:
> 
> - implement a proper PHYLIB adjust_link callback to set the duplex mode
>   accordingly
> - do not open code the fetching of a MAC address in OF/DT environments
> - demote an error message that occurs more frequently than expected in low
>   CPU/memory/bandwidth environments
> 
> Tested on a Cirrus Logic EP93xx / TS7300 board.

Series applied, thanks Florian.
