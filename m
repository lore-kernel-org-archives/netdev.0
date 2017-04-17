From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] netvsc: fix RCU warning in get_stats
Date: Mon, 17 Apr 2017 15:13:01 -0400 (EDT)
Message-ID: <20170417.151301.1309904458449506993.davem@davemloft.net>
References: <20170414214258.3367-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57114 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754194AbdDQTND (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:13:03 -0400
In-Reply-To: <20170414214258.3367-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Both patches applied but you may want to use more consistent
Subject line subsystem prefixes in the future.
