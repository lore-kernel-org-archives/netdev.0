From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/3] net: dsa: Consistently use dsa_port for dsa_*_port_{apply,unapply}
Date: Fri, 02 Jun 2017 15:32:59 -0400
Message-ID: <87fufiyyl0.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170602193123.23930-1-f.fainelli@gmail.com> <20170602193123.23930-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41128 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751208AbdFBTfE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 15:35:04 -0400
In-Reply-To: <20170602193123.23930-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> We have all the information we need in dsa_port, so use it instead of
> repeating the same arguments over and over again.
>
> Suggested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
