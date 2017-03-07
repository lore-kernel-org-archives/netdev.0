From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qcom/emac: optimize QDF2400 SGMII RX/TX impedence
 values
Date: Tue, 07 Mar 2017 12:29:19 -0800 (PST)
Message-ID: <20170307.122919.499859944877751256.davem@davemloft.net>
References: <1488323762-15195-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933239AbdCGU3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 15:29:21 -0500
In-Reply-To: <1488323762-15195-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Tue, 28 Feb 2017 17:16:02 -0600

> Adjust the impedance values of the RX and TX lanes in the SGMII block
> so that they are closer to optimal values.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied to net-next, thanks.
