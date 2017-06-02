From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/2] net: dsa: mv88e6xxx: mv88e6161 uses mv88e6320 stats snapshot
Date: Fri, 02 Jun 2017 17:28:55 -0400
Message-ID: <87inkersdk.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1496438566-30612-1-git-send-email-andrew@lunn.ch> <1496438566-30612-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49468 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBVbA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 17:31:00 -0400
In-Reply-To: <1496438566-30612-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The mv88e6161 was using the wrong method to perform statistics
> snapshot.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
