From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethoc: Make needlessly global struct ethtool_ops
 static
Date: Tue, 17 Jan 2017 15:51:11 -0500 (EST)
Message-ID: <20170117.155111.283860313087446350.davem@davemloft.net>
References: <20170117140108.1544-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        thierry.reding@gmail.com, colin.king@canonical.com,
        tremyfr@gmail.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdAQUw1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 15:52:27 -0500
In-Reply-To: <20170117140108.1544-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 17 Jan 2017 15:01:08 +0100

> Make the needlessly global struct ethtool_ops ethoc_ethtool_ops static
> to fix a sparse warning.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
