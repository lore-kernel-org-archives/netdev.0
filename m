From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 0/5] net: dsa: Multi-CPU ground work (v2)
Date: Tue, 06 Jun 2017 22:13:42 -0400
Message-ID: <87efuwtui1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170607000317.14729-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37038 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdFGCPw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 22:15:52 -0400
In-Reply-To: <20170607000317.14729-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Since you'll respin a v3, there are still a few typos here:

Florian Fainelli <f.fainelli@gmail.com> writes:

> This patch series prepares the ground for adding mutliple CPU port support to

                                                   multiple

> DSA, and starts by removing redundant pieces of information such as
> master_netdev which is cpu_dp->ethernet. Finally drivers are moved away from

                         cpu_dp->netdev

> directly accessing ds->dst->cpu_dp and use appropriate helper functions.


Thanks,

        Vivien
