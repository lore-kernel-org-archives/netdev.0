From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] synopsys: remove dwc_eth_qos driver
Date: Thu, 12 Jan 2017 10:28:02 -0500 (EST)
Message-ID: <20170112.102802.1485105708725148022.davem@davemloft.net>
References: <2d50f9fea61de2eb082b217d435334d40e3e01ad.1484214626.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, niklass@axis.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50658 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751051AbdALP2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:28:14 -0500
In-Reply-To: <2d50f9fea61de2eb082b217d435334d40e3e01ad.1484214626.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is no driver named "synopsys", therefore "synopsys: " is not an
appropriate subsystem prefix.

Subsystem prefixes have to refer to real names in the source tree in
one form or another.

I know you guys really want to rename the stmmac driver to that, but
no agreement has occurred on that issue and therefore assuming it
has happened is not appropriate.
