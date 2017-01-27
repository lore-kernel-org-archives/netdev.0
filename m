From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: micrel: add support for KSZ8795
Date: Fri, 27 Jan 2017 11:11:01 -0500 (EST)
Message-ID: <20170127.111101.1023473046170347877.davem@davemloft.net>
References: <20170127074623.9200-1-sean.nyekjaer@prevas.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch
To: sean.nyekjaer@prevas.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754933AbdA0QL1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 11:11:27 -0500
In-Reply-To: <20170127074623.9200-1-sean.nyekjaer@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
Date: Fri, 27 Jan 2017 08:46:23 +0100

> This is adds support for the PHYs in the KSZ8795 5port managed switch.
> 
> It will allow to detect the link between the switch and the soc
> and uses the same read_status functions as the KSZ8873MLL switch.
> 
> Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
> ---
> Changes in v2:
>  - Removed "switch" name

Applied, thank you.
