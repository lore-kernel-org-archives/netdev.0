From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: Fix number of CFP entries for BCM7278
Date: Wed, 30 Aug 2017 15:45:55 -0400
Message-ID: <87tw0oltzg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1504121973-8438-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58596 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdH3TtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 15:49:14 -0400
In-Reply-To: <1504121973-8438-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> BCM7278 has only 128 entries while BCM7445 has the full 256 entries set,
> fix that.
>
> Fixes: 7318166cacad ("net: dsa: bcm_sf2: Add support for ethtool::rxnfc")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
