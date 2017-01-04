From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: systemport: Fix padding vs. TSB insertion
Date: Wed, 04 Jan 2017 13:34:24 -0500 (EST)
Message-ID: <20170104.133424.901675864062162115.davem@davemloft.net>
References: <20170104003449.27078-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761710AbdADSew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 13:34:52 -0500
In-Reply-To: <20170104003449.27078-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  3 Jan 2017 16:34:47 -0800

> This patch series fixes how we pad the packets submitted to the SYSTEMPORT
> adapter, and how the transmit status block (prepended 8 bytes) fits in the
> picture. The first patch is not technically a bug fix, but is required for the
> second path to be applied and to greatly simplify the skb length calculation.

Series applied with the typo in the commit message of patch #2 fixed.

Happy new year.
