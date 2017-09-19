From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 11/12] net: dsa: bcm_sf2: Use SF2_NUM_EGRESS_QUEUES for CFP
Date: Tue, 19 Sep 2017 10:42:14 -0400
Message-ID: <87d16msqbd.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170919021947.8971-1-f.fainelli@gmail.com> <20170919021947.8971-12-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40514 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbdISOpq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 10:45:46 -0400
In-Reply-To: <20170919021947.8971-12-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> The magic number 8 in 3 locations in bcm_sf2_cfp.c actually designates the
> number of switch port egress queues, so use that define instead of open-coding
> it.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
