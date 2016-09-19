From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/2] net: dsa: mv88e6xxx: Convert flag bits to unsigned long long
Date: Mon, 19 Sep 2016 18:54:58 -0400
Message-ID: <871t0fbiv1.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1474323521-5088-1-git-send-email-andrew@lunn.ch> <1474323521-5088-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36762 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbcISWzB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 18:55:01 -0400
In-Reply-To: <1474323521-5088-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> We are soon going to run out of flag bits on 32bit systems. Convert to
> unsigned long long.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
