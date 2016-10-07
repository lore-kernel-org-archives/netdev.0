From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: phy: Correct duplicate MDIO_XGENE entry
Date: Thu, 06 Oct 2016 21:15:56 -0400 (EDT)
Message-ID: <20161006.211556.1223354956478783725.davem@davemloft.net>
References: <1475778171-10905-1-git-send-email-labbott@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: labbott@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755791AbcJGBP7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 21:15:59 -0400
In-Reply-To: <1475778171-10905-1-git-send-email-labbott@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laura Abbott <labbott@redhat.com>
Date: Thu,  6 Oct 2016 11:22:51 -0700

> An extra entry for MDIO_XGENE got added during merging.
> Delete it.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Laura Abbott <labbott@redhat.com>

Applied, thanks.
