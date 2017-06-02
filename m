From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/3] net: dsa: Pass dsa_port reference to ethtool setup/restore
Date: Fri, 02 Jun 2017 15:32:22 -0400
Message-ID: <87inkeyym1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170602193123.23930-1-f.fainelli@gmail.com> <20170602193123.23930-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41056 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751331AbdFBTec (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 15:34:32 -0400
In-Reply-To: <20170602193123.23930-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> We do not need to have a reference to a dsa_switch, instead we should
> pass a reference to a CPU dsa_port, change that. This is a preliminary
> change to better support multiple CPU ports.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
