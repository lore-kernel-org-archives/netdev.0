From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211 2017-02-28
Date: Wed, 01 Mar 2017 15:09:39 -0800 (PST)
Message-ID: <20170301.150939.1418366532271934812.davem@davemloft.net>
References: <20170228095019.10637-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753124AbdCAXLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 18:11:36 -0500
In-Reply-To: <20170228095019.10637-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 28 Feb 2017 10:50:18 +0100

> First round of fixes - we actually have quite a few.
> 
> Please pull and let me know if there's any problem.

Pulled, thanks Johannes.

> I had another question - I have this average.h API change pending
> (you saw it before). It seems it might be a good time to get it in
> now, since no new users should be showing up. If I put it in only
> with the next merge window, new users might show up and break.

Ok, you can feel free to send this now for 'net' if you like.
