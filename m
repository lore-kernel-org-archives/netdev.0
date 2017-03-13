From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/9] prepare mac operations for multiple
 queues
Date: Sun, 12 Mar 2017 23:42:40 -0700 (PDT)
Message-ID: <20170312.234240.1526601796166771418.davem@davemloft.net>
References: <cover.1489169213.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750793AbdCMGml (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:42:41 -0400
In-Reply-To: <cover.1489169213.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Fri, 10 Mar 2017 18:24:50 +0000

> As agreed with David Miller, this patch-set is the first of 3 to enable
> multiple queues in stmmac.
> 
> This first one concentrates on mac operations adding functionalities as:
> a) Configuration through DT
> b) RX and TX scheduling algorithms programming
> b) TX queues weight programming (essential in weightes algorithms)
> c) RX enable as DCB or AVB (preparing for future AVB support)
> d) Mapping RX queue to DMA channel
> e) IRQ treatment prepared for multiple queues
> f) Debug dump prepared for multiple queues
> g) CBS configuration
> 
> In v3 patch-set version I included a new patch to enable CBS configuration
> (Patch 9).

Series applied, thanks.
