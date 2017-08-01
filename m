From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] More Marvell PHY refactoring and cleanup
Date: Mon, 31 Jul 2017 18:01:49 -0700 (PDT)
Message-ID: <20170731.180149.1833039600586458597.davem@davemloft.net>
References: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48790 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751339AbdHABBu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 21:01:50 -0400
In-Reply-To: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 30 Jul 2017 22:41:43 +0200

> Consolidate more duplicated code into helpers, make use of core
> helpers, move code into a helper for later adding functionality to add
> marvell PHYs, etc.

Series applied.
