From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/2] Fixes for mv88e6161
Date: Fri, 02 Jun 2017 17:29:17 -0400
Message-ID: <87fufirscy.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1496438566-30612-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49510 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBVbV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 17:31:21 -0400
In-Reply-To: <1496438566-30612-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Testing a board with an mv88e6161 turned up two issues. The PHYs were
> not found, because the wrong method to access them was used. The
> statistics did not work, because the wrong snapshot method was used

Thanks for testing!
