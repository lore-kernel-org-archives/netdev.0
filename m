From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Move forward declaration to where it is needed
Date: Wed, 08 Feb 2017 09:38:48 -0500
Message-ID: <87efz8hhmv.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1486514401-28701-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37990 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752563AbdBHP5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 10:57:05 -0500
In-Reply-To: <1486514401-28701-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Move it out from the middle for the #defines to just before it is
> needed.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
