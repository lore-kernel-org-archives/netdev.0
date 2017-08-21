From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dsa: remove unused net_device arg from
 handlers
Date: Mon, 21 Aug 2017 10:39:42 -0700 (PDT)
Message-ID: <20170821.103942.789837047193041527.davem@davemloft.net>
References: <20170817144700.16218-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753843AbdHURjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 13:39:43 -0400
In-Reply-To: <20170817144700.16218-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 17 Aug 2017 16:47:00 +0200

> compile tested only, but saw no warnings/errors with
> allmodconfig build.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

I'll apply this for now.

Andrew says it looks OK, and if Florian F. needs it for his tag changes
we can revert.
