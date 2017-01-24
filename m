From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/5] External MDIO support for mv88e6xxx
Date: Tue, 24 Jan 2017 16:24:55 -0500
Message-ID: <87mvegxiag.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch> <20170124.153504.1132892597644436492.davem@davemloft.net> <874m0odv97.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170124.160750.354090492587505672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, netdev@vger.kernel.org, f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38248 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750860AbdAXVZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:25:28 -0500
In-Reply-To: <20170124.160750.354090492587505672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller <davem@davemloft.net> writes:

>> Andrew just replied to my comment an hour ago, and I still have concerns
>> about the patchset. I didn't like the list_head of busses, and the 6352
>> family don't support the external mode. That needed to be addressed.
>> 
>> Why such an hurry to merge patches?
>
> Because my backlog sucks otherwise?
>
> I can revert, or you can ask Andrew to post follow-on fixups to
> satisfy your concerns.  Just because I applied it doesn't make it
> the end of the world.
>
> And maybe I should apply patches aggressively, as this lights a fire
> under everyone's butt and people review and fix things more quickly.

That has exactly the opposite effect. This makes people care less about
each other work because "it's gonna be merged in a few minutes anyway."

:-)
