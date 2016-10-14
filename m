From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/7] qed*: driver updates
Date: Fri, 14 Oct 2016 12:00:21 -0400 (EDT)
Message-ID: <20161014.120021.368068785305617043.davem@davemloft.net>
References: <1476436763-5274-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com,
        manish.chopra@caviumnetworks.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48772 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbcJNQAa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 12:00:30 -0400
In-Reply-To: <1476436763-5274-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Fri, 14 Oct 2016 05:19:16 -0400

> There are several new additions in this series;
> Most are connected to either Tx offloading or Rx classifications
> [either fastpath changes or supporting configuration].
> 
> In addition, there's a single IOV enhancement.
> 
> Please consider applying this series to `net-next'.
> 
> V2->V3:
> Fixes below kbuild warning
> call to '__compiletime_assert_60' declared with
> attribute error: Need native word sized stores/loads for atomicity.
> 
> V1->V2:
> Added a fix for the race in ramrod handling
> pointed by Eric Dumazet [patch 7].

Series applied, thanks.
