From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211 2017-11-19
Date: Tue, 19 Sep 2017 10:51:52 -0700 (PDT)
Message-ID: <20170919.105152.177811123366621975.davem@davemloft.net>
References: <20170919072048.8484-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37744 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdISRvx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:51:53 -0400
In-Reply-To: <20170919072048.8484-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 19 Sep 2017 09:20:47 +0200

> Here's a new set of two small changes to prevent null pointer
> dereferences on malformed netlink messages.
> 
> Please pull and let me know if there's any problem.

Pulled, thank you.
