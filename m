From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] remove dwc_eth_qos and rename stmicro/stmmac
Date: Wed, 11 Jan 2017 10:20:00 -0500 (EST)
Message-ID: <20170111.102000.1291650495305959047.davem@davemloft.net>
References: <0dcdcb5f-200b-b130-9a67-774639353114@st.com>
        <20170111.095256.1057845755758556047.davem@davemloft.net>
        <329b0d8c-4cda-7238-c229-d69ac251f26b@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexandre.torgue@st.com, lars.persson@axis.com, niklass@axis.com,
        peppe.cavallaro@st.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50958 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752571AbdAKPUD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:20:03 -0500
In-Reply-To: <329b0d8c-4cda-7238-c229-d69ac251f26b@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed, 11 Jan 2017 15:06:55 +0000

> The goal of this work is to improve code organization and future merge of other
> Synopsys Ethernet IP driver that will be able to merge into this "synopsys
> driver bundle". That is why I volunteered to merge the dwc qos axis' driver into
> stmmac.

Then I want to see an ACK from Alexandre and Peppe for this renaming
patch set.
