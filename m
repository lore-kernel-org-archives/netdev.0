From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched/hfsc: allocate tcf block for hfsc root class
Date: Fri, 11 Aug 2017 14:31:00 -0700 (PDT)
Message-ID: <20170811.143100.1181788749464507615.davem@davemloft.net>
References: <150235750037.493227.16245118631720190134.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, jhs@mojatatu.com
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753806AbdHKVbB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:31:01 -0400
In-Reply-To: <150235750037.493227.16245118631720190134.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 10 Aug 2017 12:31:40 +0300

> Without this filters cannot be attached.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 6529eaba33f0 ("net: sched: introduce tcf block infractructure")

Applied, thanks.
