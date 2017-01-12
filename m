From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] synopsys: remove dwc_eth_qos driver
Date: Thu, 12 Jan 2017 10:48:03 -0500 (EST)
Message-ID: <20170112.104803.240247212224131685.davem@davemloft.net>
References: <2d50f9fea61de2eb082b217d435334d40e3e01ad.1484214626.git.jpinto@synopsys.com>
        <20170112.102802.1485105708725148022.davem@davemloft.net>
        <0eb32fee-0354-522d-72c4-3d1105ec04ed@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, niklass@axis.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51054 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdALPsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:48:05 -0500
In-Reply-To: <0eb32fee-0354-522d-72c4-3d1105ec04ed@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Thu, 12 Jan 2017 15:46:31 +0000

> Hope we can meet in a LinuxCon soon and have a talk, for you to know
> me and this way you will see that I am a guy that is only focused in
> producing work the best way possible, and nothing else.

I do not argue your intentions.

I argue the side effects of your change for the ecosystem of
long term maintaince and backporting, and what tangible benefit
this change brings to users.
