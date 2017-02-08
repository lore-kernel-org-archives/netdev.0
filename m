From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Move forward declaration to where
 it is needed
Date: Wed, 08 Feb 2017 14:46:42 -0500 (EST)
Message-ID: <20170208.144642.2148475498749388901.davem@davemloft.net>
References: <1486514401-28701-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57530 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdBHTrw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:47:52 -0500
In-Reply-To: <1486514401-28701-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed,  8 Feb 2017 01:40:01 +0100

> Move it out from the middle for the #defines to just before it is
> needed.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

This looks like net-next material to me, but this patch doesn't apply there.
