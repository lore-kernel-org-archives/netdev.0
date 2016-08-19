From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] qed*: Fix ethtool issues relating to link
Date: Thu, 18 Aug 2016 23:06:20 -0700 (PDT)
Message-ID: <20160818.230620.224199001701245225.davem@davemloft.net>
References: <1471584898-23253-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42317 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbcHSGGV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:06:21 -0400
In-Reply-To: <1471584898-23253-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Fri, 19 Aug 2016 08:34:56 +0300

> This series addresses two issues that were introduced when adding
> support for ethtool's link_ksettings support - the first fixes a
> regression and second incorrect functionallity in the submission.
> 
> Although these are fixes, as the feature currently exists only in
> 'next-next' I'm aiming them for it.
> 
> Dave, please consider applying this series to 'net-next'.

Series applied, thank you.
