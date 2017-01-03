From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] dsa:mv88e6xxx: allow address 0x1 in
 smi_init
Date: Tue, 03 Jan 2017 10:02:21 -0500 (EST)
Message-ID: <20170103.100221.2200900537461778187.davem@davemloft.net>
References: <1483436949-4527-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
To: volodymyr.bendiuga@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37358 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935399AbdACPCX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 10:02:23 -0500
In-Reply-To: <1483436949-4527-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Date: Tue,  3 Jan 2017 10:49:09 +0100

> From: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> 
> Some devices, such as the mv88e6097 do have ADDR[0] external and so it
> is possible to configure the device to use SMI address 0x1. Remove the
> restriction, as there are boards using this address.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
