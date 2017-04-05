From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] bnxt_en: Updates for net-next.
Date: Wed, 05 Apr 2017 06:24:57 -0700 (PDT)
Message-ID: <20170405.062457.1760391369094821798.davem@davemloft.net>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41854 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933366AbdDENZL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 09:25:11 -0400
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Tue,  4 Apr 2017 18:14:05 -0400

> Main changes are to add WoL and selftest features, optimize XDP_TX by
> using short BDs, and to cap the usage of MSIX.

Series applied, thanks Michael.
