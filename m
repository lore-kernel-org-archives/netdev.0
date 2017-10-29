From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 net-next 00/13] gtp: Additional feature support -
 Part I
Date: Sun, 29 Oct 2017 10:49:31 +0900 (KST)
Message-ID: <20171029.104931.279145966336908779.davem@davemloft.net>
References: <CAPDqMer558X27F6F0HqrWVPyAWmTZaLuJ-NmRXP7i4Z-iycfxw@mail.gmail.com>
        <20171028164759.5nm7dfpsdqpxewt6@nataraja>
        <CALx6S35R5hK8DMndXRcTHmapavdCFs5YDtdbca3yTznagNXqig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, tom@quantonium.net, pablo@netfilter.org,
        aschultz@tpip.net, netdev@vger.kernel.org, rohit@quantonium.net
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751582AbdJ2Btg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 21:49:36 -0400
In-Reply-To: <CALx6S35R5hK8DMndXRcTHmapavdCFs5YDtdbca3yTznagNXqig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Sat, 28 Oct 2017 11:37:51 -0700

> Customers are using IPv6!

Customers aren't using GTP with ipv6 the way you have implemented it.

Please stop weasel-wording the situation to frame it in a way that
purely benefits you and your objectives.

Also, just because "nobody has done the work", doesn't mean it's OK to
do the work improperly and then force that implementation upon people.

Harald is right, calling something GTP/ipv6 sets a certain expectation
with people who actually use GTP with ipv6 and have a deployment.  No
matter if you mark it EXPERIMENTAL or whatever, the effect is the
same.

Therefore, I fully agree with Harald.
