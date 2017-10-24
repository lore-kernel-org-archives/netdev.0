From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: check master device before put
Date: Tue, 24 Oct 2017 18:43:18 +0900 (KST)
Message-ID: <20171024.184318.1296211169971425498.davem@davemloft.net>
References: <20171023180141.3674-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58308 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdJXJnX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:43:23 -0400
In-Reply-To: <20171023180141.3674-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 23 Oct 2017 14:01:41 -0400

> In the case of pdata, the dsa_cpu_parse function calls dev_put() before
> making sure it isn't NULL. Fix this.
> 
> Fixes: 71e0bbde0d88 ("net: dsa: Add support for platform data")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Please submit a 'net' version of this patch and then please patiently
wait for it to be properly merged and propagated into 'net-next'.

Thank you.
