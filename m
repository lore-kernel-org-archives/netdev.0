From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] synopsys: remove dwc_eth_qos driver
Date: Thu, 12 Jan 2017 11:03:35 -0500 (EST)
Message-ID: <20170112.110335.1009105224491052711.davem@davemloft.net>
References: <0eb32fee-0354-522d-72c4-3d1105ec04ed@synopsys.com>
        <20170112.104803.240247212224131685.davem@davemloft.net>
        <066a57f3-29b5-c297-cd67-d9c937b9c9d9@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, niklass@axis.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750863AbdALQDi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:03:38 -0500
In-Reply-To: <066a57f3-29b5-c297-cd67-d9c937b9c9d9@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Thu, 12 Jan 2017 15:54:39 +0000

> I know that changing what is working properly is a risk, I totally understand,
> and if I was a top maintainer I would have the same concern

I'm not saying you risk breaking anything.

I'm saying you will make backporting bug fixes to older releases for
me and every distribution maintainer unreasonably difficult.
