From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211 2017-01-06
Date: Fri, 06 Jan 2017 16:27:25 -0500 (EST)
Message-ID: <20170106.162725.481874783893198568.davem@davemloft.net>
References: <20170106123721.10970-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932358AbdAFV11 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 16:27:27 -0500
In-Reply-To: <20170106123721.10970-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri,  6 Jan 2017 13:37:20 +0100

> Here's another fix for something I noticed while reviewing the code in
> a new suggested patch that added another netlink socket destroy path.
> 
> Since the new patch would otherwise cause conflicts, it might be good
> to pull net or Linus's next RC containing it into net-next, if you can.
> 
> Please pull and let me know if there's any problem.

Pulled, I'll try to get this moving into net-next over the weekend.

Remind me about this early next week if that ends up slipping through
the cracks.

Thanks.
