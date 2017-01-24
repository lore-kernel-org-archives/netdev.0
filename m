From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] External MDIO support for mv88e6xxx
Date: Tue, 24 Jan 2017 16:07:50 -0500 (EST)
Message-ID: <20170124.160750.354090492587505672.davem@davemloft.net>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
        <20170124.153504.1132892597644436492.davem@davemloft.net>
        <874m0odv97.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org, f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33090 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751080AbdAXVHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:07:51 -0500
In-Reply-To: <874m0odv97.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 24 Jan 2017 16:05:08 -0500

> Hi David,
> 
> David Miller <davem@davemloft.net> writes:
> 
>> Series applied, thanks Andrew.
>>
>> There seems to be a bit of inconsistency wrt. tab vs. space for
>> indentation in the binding files, just FYI.  I had to make some small
>> adjustments to this patch series in order to keep GIT from warning
>> when I applied this stuff.
> 
> Andrew just replied to my comment an hour ago, and I still have concerns
> about the patchset. I didn't like the list_head of busses, and the 6352
> family don't support the external mode. That needed to be addressed.
> 
> Why such an hurry to merge patches?

Because my backlog sucks otherwise?

I can revert, or you can ask Andrew to post follow-on fixups to
satisfy your concerns.  Just because I applied it doesn't make it
the end of the world.

And maybe I should apply patches aggressively, as this lights a fire
under everyone's butt and people review and fix things more quickly.

:-)
