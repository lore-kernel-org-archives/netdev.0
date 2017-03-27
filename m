From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: stmmac: fix number of tx queues in
 stmmac_poll
Date: Mon, 27 Mar 2017 14:00:19 -0700 (PDT)
Message-ID: <20170327.140019.1978414421735502646.davem@davemloft.net>
References: <20170327170058.GA8441@Red>
        <20170327.102831.1248194814523871799.davem@davemloft.net>
        <c8ec25cb-0369-a1b3-9f5b-dfd1ed6f9148@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clabbe.montjoie@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, thierry.reding@gmail.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752271AbdC0VA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 17:00:28 -0400
In-Reply-To: <c8ec25cb-0369-a1b3-9f5b-dfd1ed6f9148@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Mon, 27 Mar 2017 18:44:22 +0100

> For what I am understanding, SoCs base on Core versions >= 4.00 are working
> properly and for some reason SoCs based on older versions are not working.

Please send me a revert, and work offline with these people to resolve
all of the regressions you introduced.

Once you resolved all of the regressions, we can put the changes back
in.

Thank you.
