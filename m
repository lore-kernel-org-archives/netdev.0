From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: remove unused ifla_stats_policy
Date: Fri, 09 Sep 2016 16:53:07 -0700 (PDT)
Message-ID: <20160909.165307.2004247327970077107.davem@davemloft.net>
References: <20160907135736.7a986302@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbcIIXxI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:53:08 -0400
In-Reply-To: <20160907135736.7a986302@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 7 Sep 2016 13:57:36 -0700

> This structure is defined but never used. Flagged with W=1
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
