From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next 0/5] Interrupt support for mv88e6xxx
Date: Tue, 18 Oct 2016 15:20:54 -0400
Message-ID: <87pomxihux.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1476640613-25365-1-git-send-email-andrew@lunn.ch> <87r37dlccl.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me> <20161018185729.GB15180@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36043 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934818AbcJRTU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 15:20:57 -0400
In-Reply-To: <20161018185729.GB15180@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> mv88e6xxx_g1_* should've been moved to global1.c, I'll move them
>> later.
>
> Hi Vivian
>
> I did consider that, but at the moment, there are only access
> functions in there. But the code should be easy to move.

True, looks good to me like this for the moment :-)

Thanks,

        Vivien
