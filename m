From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: remove version string
Date: Fri, 06 Jan 2017 15:49:53 -0500 (EST)
Message-ID: <20170106.154953.1750089711039854519.davem@davemloft.net>
References: <20170105172841.16221-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40840 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936137AbdAFUtz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:49:55 -0500
In-Reply-To: <20170105172841.16221-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu,  5 Jan 2017 12:28:41 -0500

> The dsa_driver_version string is irrelevant and has not been bumped
> since its introduction about 9 years ago. Kill it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
