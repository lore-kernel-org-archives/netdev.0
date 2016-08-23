From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] qed*: IOV patch series
Date: Mon, 22 Aug 2016 18:28:34 -0700 (PDT)
Message-ID: <20160822.182834.501314493983525327.davem@davemloft.net>
References: <1471861512-30104-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47337 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753509AbcHWB2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 21:28:38 -0400
In-Reply-To: <1471861512-30104-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 22 Aug 2016 13:25:08 +0300

> Recent FW [8.10.10.0] enabled us to support sriov interaction
> with legacy VF/PF. This patch series adds the necessary driver changes
> to utilize this additional compatibility.
> In addition, utilize the new FW ability to prevent pause floods by VFs,
> and fix a bug that is [mostly] exposed by the added legacy support.

Series applied, thanks.
