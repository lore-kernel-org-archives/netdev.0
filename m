From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Fix inverted test for multiple CPU
 interface
Date: Tue, 24 Jan 2017 13:34:41 -0500 (EST)
Message-ID: <20170124.133441.775347697059759939.davem@davemloft.net>
References: <1485119805-30338-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAXSe7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 13:34:59 -0500
In-Reply-To: <1485119805-30338-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 22 Jan 2017 22:16:45 +0100

> Remove the wrong !, otherwise we get false positives about having
> multiple CPU interfaces.
> 
> Fixes: b22de490869d ("net: dsa: store CPU switch structure in the tree")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
