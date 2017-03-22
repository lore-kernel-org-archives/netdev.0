From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: stmmac: Always enable MAC RX queues
Date: Wed, 22 Mar 2017 12:15:36 -0700 (PDT)
Message-ID: <20170322.121536.1098152403192198479.davem@davemloft.net>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        Joao.Pinto@synopsys.com, clabbe.montjoie@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thierry.reding@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758611AbdCVTPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 15:15:38 -0400
In-Reply-To: <20170321151211.31841-1-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <thierry.reding@gmail.com>
Date: Tue, 21 Mar 2017 16:12:09 +0100

> From: Thierry Reding <treding@nvidia.com>
> 
> The MAC RX queues always need to be enabled in order to receive network
> packets. Remove the condition that this only needs to be done for multi-
> queue configurations.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>

Applied to net-next
