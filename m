From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net-tcp: retire TFO_SERVER_WO_SOCKOPT2
 config
Date: Tue, 23 Aug 2016 17:01:23 -0700 (PDT)
Message-ID: <20160823.170123.844041076028023068.davem@davemloft.net>
References: <1471911474-16898-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, piotr.jerzy.jurkiewicz@gmail.com,
        edumazet@google.com, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55925 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754073AbcHXABY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:01:24 -0400
In-Reply-To: <1471911474-16898-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 22 Aug 2016 17:17:54 -0700

> TFO_SERVER_WO_SOCKOPT2 was intended for debugging purposes during
> Fast Open development. Remove this config option and also
> update/clean-up the documentation of the Fast Open sysctl.
> 
> Reported-by: Piotr Jurkiewicz <piotr.jerzy.jurkiewicz@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
