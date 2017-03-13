From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 12/17] net: dsa: add dsa_is_normal_port helper
Date: Mon, 13 Mar 2017 10:54:35 -0400
Message-ID: <871su1p6qc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com> <20170311211303.24560-13-vivien.didelot@savoirfairelinux.com> <e2553201-b071-b0e5-30c2-13cf81ea6101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54328 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753328AbdCMOzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 10:55:48 -0400
In-Reply-To: <e2553201-b071-b0e5-30c2-13cf81ea6101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Le 03/11/17 à 13:12, Vivien Didelot a écrit :
>> Introduce a dsa_is_normal_port helper to check if a given port is a
>> normal user port as opposed to a CPU port or DSA link.
>
> net/dsa/dsa2.c uses the "user" terminology should we use something like
> that here?

I used the one suggested by Andrew, but I wouldn't mind using "user"
here if it makes more sense.

Thanks,

        Vivien
