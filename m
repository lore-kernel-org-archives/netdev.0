From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: use the new rtnl_get_event()
 interface
Date: Wed, 31 May 2017 13:08:48 -0400 (EDT)
Message-ID: <20170531.130848.1888796229681598626.davem@davemloft.net>
References: <1496153222-13382-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41242 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbdEaRIu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 13:08:50 -0400
In-Reply-To: <1496153222-13382-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue, 30 May 2017 10:07:02 -0400

> Small clean-up to rtmsg_ifinfo() to use the rtnl_get_event()
> interface instead of using 'internal' values directly.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
