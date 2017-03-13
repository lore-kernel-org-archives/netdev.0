From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: set default number of rx and tx queues in
 stmmac_pci
Date: Mon, 13 Mar 2017 12:12:59 -0700 (PDT)
Message-ID: <20170313.121259.2282966988475158031.davem@davemloft.net>
References: <d8f9e892defdcaf7f7e5fe795f2072b16f7e6b87.1489399548.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54116 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751689AbdCMTNd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 15:13:33 -0400
In-Reply-To: <d8f9e892defdcaf7f7e5fe795f2072b16f7e6b87.1489399548.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Mon, 13 Mar 2017 10:07:07 +0000

> This patch configures default number of RX and TX queues when
> using the pci glue driver.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

This is a net-next specific patch, you must the target tree properly in your
Subject line or similar, for example:

	[PATCH net-next] stmmac: set default ...

I'm taking care of this, and for the next patch too, but in the future you
need to be clear what tree your changes are targetting.

Thanks.
