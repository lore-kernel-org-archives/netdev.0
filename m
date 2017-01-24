From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/5] External MDIO support for mv88e6xxx
Date: Tue, 24 Jan 2017 16:05:08 -0500
Message-ID: <874m0odv97.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch> <20170124.153504.1132892597644436492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37012 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751043AbdAXVLw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:11:52 -0500
In-Reply-To: <20170124.153504.1132892597644436492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller <davem@davemloft.net> writes:

> Series applied, thanks Andrew.
>
> There seems to be a bit of inconsistency wrt. tab vs. space for
> indentation in the binding files, just FYI.  I had to make some small
> adjustments to this patch series in order to keep GIT from warning
> when I applied this stuff.

Andrew just replied to my comment an hour ago, and I still have concerns
about the patchset. I didn't like the list_head of busses, and the 6352
family don't support the external mode. That needed to be addressed.

Why such an hurry to merge patches?

    Vivien
