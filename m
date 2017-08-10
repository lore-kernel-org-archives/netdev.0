From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] rtnetlink: fix initial rtnl pushdown
 fallout
Date: Thu, 10 Aug 2017 09:50:39 -0700 (PDT)
Message-ID: <20170810.095039.713761198958854744.davem@davemloft.net>
References: <20170810145302.30391-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752283AbdHJQuk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:50:40 -0400
In-Reply-To: <20170810145302.30391-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 10 Aug 2017 16:52:56 +0200

> This series fixes various bugs and splats reported since the
> allow-handler-to-run-with-no-rtnl series went in.
> 
> Last patch adds a script that can be used to add further
> tests in case more bugs are reported.
> In case you prefer reverting the original series instead of
> fixing fallout I can resend this patch on its own.

Series applied, thanks Florian.
