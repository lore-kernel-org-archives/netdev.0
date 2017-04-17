From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: dsa: isolate legacy code
Date: Mon, 17 Apr 2017 11:03:30 -0400 (EDT)
Message-ID: <20170417.110330.1378120902638943806.davem@davemloft.net>
References: <20170412164503.28264-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752107AbdDQPDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 11:03:32 -0400
In-Reply-To: <20170412164503.28264-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 12 Apr 2017 12:45:03 -0400

> This patch moves as is the legacy DSA code from dsa.c to legacy.c,
> except the few shared symbols which remain in dsa.c.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
> Changes in v2:
>   - drop CONFIG_NET_DSA_LEGACY so that legacy code gets compiled anyway

Applied, thanks.
