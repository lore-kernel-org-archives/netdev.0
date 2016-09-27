From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: qcom/emac: do not use devm on internal phy
 pdev
Date: Tue, 27 Sep 2016 03:34:43 -0400 (EDT)
Message-ID: <20160927.033443.2028073957490302688.davem@davemloft.net>
References: <1474640854-1698-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linaro-acpi@lists.linaro.org,
        linux-arm-kernel@lists.infradead.org, shankerd@codeaurora.org,
        vikrams@codeaurora.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43878 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752132AbcI0Her (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 03:34:47 -0400
In-Reply-To: <1474640854-1698-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch doesn't apply to net-next.

Also, when you send a patch series, you must send an initial
posting with Subject of the form "[PATCH {net,net-next} 0/2] ..."
explaining at a high level what your patch series is doing,
how it is doing it, and why it is doing it that way.

Thanks.
