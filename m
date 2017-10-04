From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: core: fix kerneldoc comment
Date: Wed, 04 Oct 2017 10:28:43 -0700 (PDT)
Message-ID: <20171004.102843.1825282330008026345.davem@davemloft.net>
References: <20171004115650.6406-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751188AbdJDR2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 13:28:44 -0400
In-Reply-To: <20171004115650.6406-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  4 Oct 2017 13:56:50 +0200

> net/core/dev.c:1306: warning: No description found for parameter 'name'
> net/core/dev.c:1306: warning: Excess function parameter 'alias' description in 'dev_get_alias'
> 
> Fixes: 6c5570016b97 ("net: core: decouple ifalias get/set from rtnl lock")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
