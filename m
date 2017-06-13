From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211-next 2017-06-13
Date: Tue, 13 Jun 2017 13:53:13 -0400 (EDT)
Message-ID: <20170613.135313.1195087934000612946.davem@davemloft.net>
References: <20170613122223.2386-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46136 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752168AbdFMRxP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:53:15 -0400
In-Reply-To: <20170613122223.2386-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 13 Jun 2017 14:22:21 +0200

> Looks like I haven't sent you anything for a long time, so here
> we go. There isn't a ton of things, but in particular the 4-way-
> handshake offload has been a long time in the making.

Looks good, pulled, thanks Johannes.

> I'll send you the conversion for more skb_put_zero() users in a
> separate patch after this.

Ok.
