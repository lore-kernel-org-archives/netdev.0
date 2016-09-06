From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] qed*: Debug data collection
Date: Tue, 06 Sep 2016 14:24:31 -0700 (PDT)
Message-ID: <20160906.142431.482345592281427034.davem@davemloft.net>
References: <1473075312-19075-1-git-send-email-Tomer.Tayar@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: Tomer.Tayar@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755260AbcIFVYc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 17:24:32 -0400
In-Reply-To: <1473075312-19075-1-git-send-email-Tomer.Tayar@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@qlogic.com>
Date: Mon, 5 Sep 2016 14:35:09 +0300

> This patch series adds the support of debug data collection in the qed driver,
> and the means to extract it in the qede driver via the get_regs operation.
 ...
> Please consider applying this to 'net-next'.

There are conflicts due to another qed patch I applied to net-next,
please respin.

Thanks.
