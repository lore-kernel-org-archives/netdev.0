From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Thu, 12 Jan 2017 10:26:30 -0500 (EST)
Message-ID: <20170112.102630.1448382649844350511.davem@davemloft.net>
References: <a2d2e457-47e5-bb73-a059-0cb907a29ae0@synopsys.com>
        <57d96ccb-7fd4-0707-4902-a5bdd2a6ef39@st.com>
        <dbb59d07-4ab4-37d2-5e70-073091749445@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexandre.torgue@st.com, f.fainelli@gmail.com,
        lars.persson@axis.com, niklass@axis.com, peppe.cavallaro@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50598 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750793AbdALP0d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:26:33 -0500
In-Reply-To: <dbb59d07-4ab4-37d2-5e70-073091749445@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I don't understand at all why it is so important to change the name of
these files nor the directory they live in.

What bonafide benefit will users receive if we do this?

The only clear part is the downside, which is that it is going to make
it painful to browse source history and backport bug fixes.

Please, let's not do this.

Thanks.
