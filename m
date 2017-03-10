From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/9] prepare mac operations for multiple
 queues
Date: Fri, 10 Mar 2017 09:50:11 -0800 (PST)
Message-ID: <20170310.095011.2233077499571268155.davem@davemloft.net>
References: <cover.1489146580.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59928 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755028AbdCJRuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 12:50:13 -0500
In-Reply-To: <cover.1489146580.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Fri, 10 Mar 2017 12:18:25 +0000

> As agreed with David Miller, this patch-set is the first of 3 to enable
> multiple queues in stmmac.

I have one more request to make.

The name of the driver is "stmmac" therefore I'd like you to use
"stmmac: " as the subsystem prefix in your Subject lines just as
everyone else who works on this driver does.  Please don't use
"stmicro: " thank you.
