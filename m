From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 net-next 1/5] net: dsa: mv88e6xxx: Move phy functions into phy.[ch]
Date: Thu, 25 May 2017 19:19:36 -0400
Message-ID: <87r2zced87.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1495753404-29943-1-git-send-email-andrew@lunn.ch> <1495753404-29943-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40340 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030469AbdEYXVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 19:21:38 -0400
In-Reply-To: <1495753404-29943-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The upcoming SERDES support will need to make use of PHY functions. Move
> them out into a file of there own. No code changes.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
