From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] qed: IOV related clenaups
Date: Tue, 21 Mar 2017 19:02:51 -0700 (PDT)
Message-ID: <20170321.190251.1441053484481490457.davem@davemloft.net>
References: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdCVCCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 22:02:53 -0400
In-Reply-To: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sun, 19 Mar 2017 13:08:11 +0200

> This patch series targets IOV functionality [on both PF and VF].
> 
> Patches #2, #3 and #5 fix flows relating to malicious VFs, either by
> upgrading and aligning current safe-guards or by correcing racy flows.
> 
> Patches #1 and #8 make some malicious/dysnfunctional VFs logging appear
> by default in logs.
> 
> The rest of the patches either cleanup the existing code or else correct
> some possible [yet fairly insignicant] issues in VF behavior.

Series applied, thank you.
