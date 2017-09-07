From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: remove unnecessary call to dev_net()
Date: Wed, 06 Sep 2017 21:26:13 -0700 (PDT)
Message-ID: <20170906.212613.52886948289511744.davem@davemloft.net>
References: <20170906090806.20931-1-kleber.souza@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
        ying.xue@windriver.com
To: kleber.souza@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbdIGE0P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 00:26:15 -0400
In-Reply-To: <20170906090806.20931-1-kleber.souza@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kleber Sacilotto de Souza <kleber.souza@canonical.com>
Date: Wed,  6 Sep 2017 11:08:06 +0200

> The net device is already stored in the 'net' variable, so no need to call
> dev_net() again.
> 
> Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>

Applied, thanks.
