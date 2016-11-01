From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qcom/emac: use correct value for
 SGMII_LN_UCDR_SO_GAIN_MODE0
Date: Tue, 01 Nov 2016 12:14:51 -0400 (EDT)
Message-ID: <20161101.121451.1534479710221306033.davem@davemloft.net>
References: <1477955922-18276-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47332 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbcKAQOx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:14:53 -0400
In-Reply-To: <1477955922-18276-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Mon, 31 Oct 2016 18:18:42 -0500

> The documentation says that SGMII_LN_UCDR_SO_GAIN_MODE0 should be
> set to 0, not 6, on the Qualcomm Technologies QDF2432.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied.
