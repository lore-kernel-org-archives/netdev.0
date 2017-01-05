From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethoc: Remove unused members from struct ethoc
Date: Thu, 05 Jan 2017 11:27:28 -0500 (EST)
Message-ID: <20170105.112728.224736003392325201.davem@davemloft.net>
References: <20170105081627.29146-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        thierry.reding@gmail.com, andrew@lunn.ch, colin.king@canonical.com,
        tremyfr@gmail.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38006 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031348AbdAEQ1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 11:27:31 -0500
In-Reply-To: <20170105081627.29146-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  5 Jan 2017 09:16:27 +0100

> The io_region_size and dma_alloc members of struct ethoc are only
> written but never read, so they might as well be removed.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
