From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] net: stmmac: adding multiple buffers
 and routing
Date: Tue, 21 Mar 2017 17:24:15 -0700 (PDT)
Message-ID: <20170321.172415.220434094284460335.davem@davemloft.net>
References: <cover.1489766674.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757696AbdCVAYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 20:24:17 -0400
In-Reply-To: <cover.1489766674.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Fri, 17 Mar 2017 16:11:04 +0000

> As agreed with David Miller, this patch-set is the third and last to enable
> multiple queues in stmmac.
> 
> This third one focuses on:
> 
> a) Enable multiple buffering to the driver and queue independent data
> b) Configuration of RX and TX queues' priority
> c) Configuration of RX queues' routing

Series applied, thanks.
