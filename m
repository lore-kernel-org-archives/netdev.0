From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix inconsistent teardown and release of private
 netdev state.
Date: Fri, 09 Jun 2017 13:14:25 -0400 (EDT)
Message-ID: <20170609.131425.2115631648981556337.davem@davemloft.net>
References: <1497012325.2424.12.camel@sipsolutions.net>
        <20170609.101733.1675759409997288763.davem@davemloft.net>
        <1497018827.12088.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdFIRO1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 13:14:27 -0400
In-Reply-To: <1497018827.12088.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 09 Jun 2017 16:33:47 +0200

> Right. Do you want me to put that into my tree? I could do it tonight,
> or perhaps only Monday though.

Please submit it formally to netdev for me to apply.

I want to queue it up with the original patch for -stable to make
sure all the fallout is addressed.

Thank you.
