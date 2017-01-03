From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net: dsa: remove out label in dsa_switch_setup_one
Date: Tue, 03 Jan 2017 14:18:55 -0500
Message-ID: <87inpweyu8.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com> <20170103181538.2593-2-vivien.didelot@savoirfairelinux.com> <20170103183913.GB30638@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, cphealy@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49954 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757934AbdACTTa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 14:19:30 -0500
In-Reply-To: <20170103183913.GB30638@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Tue, Jan 03, 2017 at 01:15:36PM -0500, Vivien Didelot wrote:
>> The "out" label in dsa_switch_setup_one() is useless, thus remove it.
>
> Hi Vivien
>
> Missing a SOB.
>
> This one patch i'm happy with. Assuming we drop the other two, please
> could you submit this on its own.
>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

You're right, thanks, will do.

       Vivien
