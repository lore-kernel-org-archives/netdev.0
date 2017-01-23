From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: stmicro: dwmac4 comments enhancement
Date: Mon, 23 Jan 2017 11:20:42 -0500 (EST)
Message-ID: <20170123.112042.989220998426190929.davem@davemloft.net>
References: <4b0ae13cd5076f1830bae79e1ad9bd0542d0e2bf.1485186686.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43468 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAWQUo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:20:44 -0500
In-Reply-To: <4b0ae13cd5076f1830bae79e1ad9bd0542d0e2bf.1485186686.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Mon, 23 Jan 2017 15:56:24 +0000

> + * This is the driver for the DesignWare Ethernet QoS Controller.

This is fine.

> + * For historical reasons it started in 4.x version.

This provides no value whatsoever.

Please resist the urge to fidget and adjust random things, just get to
the point and make the minimum change necessary to achieve a specific,
well defined, constrained, objective.

Please!

I'm really getting irritated with how much effort is being expended
to make dilly-dally style changes that provide little or no value
to the driver.

Fix bugs and contribute new support for new chips, because this stuff
I'm seeing here is just eating up everyone's time rather than improving
the driver.

Thank you.
