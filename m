From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] ravb: Support 1Gbps on R-Car H3 ES1.1+
 and R-Car M3-W
Date: Sun, 29 Jan 2017 18:36:37 -0500 (EST)
Message-ID: <20170129.183637.1519401740877958836.davem@davemloft.net>
References: <1485542120-10205-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, magnus.damm@gmail.com,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: horms+renesas@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750805AbdA2Xgk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 18:36:40 -0500
In-Reply-To: <1485542120-10205-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms+renesas@verge.net.au>
Date: Fri, 27 Jan 2017 19:35:18 +0100

> this series adds support for gigabit communication to the Renesas EthernetAVB
> controller when used in conjunction with  R-Car Gen3 H3 ES1.1+ and M3-W SoCs.
> Gigabit is already supported with R-Car Gen 2 SoCs.
> 
> The patch from Geert was previously posted for inclusion in v4.10 and
> acked by Dave for that purpose. It was, however, not accepted by the
> ARM SoC maintainers.
> 
> The path from Mizuguchi-san is to address timing problems observed with
> gigabit transfers. I would like it considered although my own testing on
> M3-W did not show any timing problems.

Series applied, thanks Simon.
