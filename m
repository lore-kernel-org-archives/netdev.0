From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Thu, 12 Jan 2017 10:45:39 -0500 (EST)
Message-ID: <20170112.104539.326369092090046644.davem@davemloft.net>
References: <dbb59d07-4ab4-37d2-5e70-073091749445@synopsys.com>
        <20170112.102630.1448382649844350511.davem@davemloft.net>
        <3ec17612-255f-5fc7-02c6-9ba5b76d2c09@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexandre.torgue@st.com, f.fainelli@gmail.com,
        lars.persson@axis.com, niklass@axis.com, peppe.cavallaro@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751236AbdALPpv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:45:51 -0500
In-Reply-To: <3ec17612-255f-5fc7-02c6-9ba5b76d2c09@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Thu, 12 Jan 2017 15:39:47 +0000

> In my understanding the advantage is to prepare the future.

If the driver is named foo or bar, yet in both cases loads and
properly attaches to the user's device, the user does not care.

Therefore, there is no bonafide benefit to the user.

You aren't getting past that point.

You also are not addressing the pain this will cause for long
term maintainence of this driver.

I'm the one who does all of the backporting of stmmac bug fixes to
-stable, so I for one care a lot about this.

You are making more work for me and lots of other people by renaming
this driver and I don't think you are considering that at all.
