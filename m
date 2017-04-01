From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/9] net: dsa: mv88e6xxx: program
 cross-chip bridging
Date: Sat, 01 Apr 2017 12:23:49 -0700 (PDT)
Message-ID: <20170401.122349.1411474095004148070.davem@davemloft.net>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751385AbdDATXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 15:23:51 -0400
In-Reply-To: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 30 Mar 2017 17:37:06 -0400

> The purpose of this patch series is to bring hardware cross-chip
> bridging configuration to the DSA layer and the mv88e6xxx DSA driver.

This series seems like a step in the right direction so I have applied
it to net-next.  We can address non-PVT setups and other issues in
follow-up changes.

Thanks!
