From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net-next: stmmac: Convert new_state to bool
Date: Sun, 21 May 2017 13:28:15 -0400 (EDT)
Message-ID: <20170521.132815.1029482185989797675.davem@davemloft.net>
References: <20170519070335.1604-1-clabbe.montjoie@gmail.com>
        <20170519070335.1604-2-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45018 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752959AbdEUR2R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:28:17 -0400
In-Reply-To: <20170519070335.1604-2-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Fri, 19 May 2017 09:03:32 +0200

> This patch convert new_state from int to bool since it store only 1 or 0
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

You must also change it to use the values "true" and "false" as well.

Thanks.
