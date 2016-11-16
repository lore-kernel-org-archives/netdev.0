From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] Fixes for the MV88e6xxx interrupt code
Date: Wed, 16 Nov 2016 14:21:02 -0500 (EST)
Message-ID: <20161116.142102.1586244273660874282.davem@davemloft.net>
References: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753140AbcKPTVE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 14:21:04 -0500
In-Reply-To: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 16 Nov 2016 01:56:50 +0100

> The interrupt code was never tested with a board who's probing
> resulted in an -EPROBE_DEFFERED. So the clean up paths never got
> tested. I now do have -EPROBE_DEFFERED, and things break badly during
> cleanup. These are the fixes.
> 
> This is fixing code in net-next.

Series applied, thanks Andrew.
