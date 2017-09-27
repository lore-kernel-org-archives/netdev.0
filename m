From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/6] net: dsa: mv88e6xxx: Print offending port when vlan check fails
Date: Wed, 27 Sep 2017 11:49:23 -0400
Message-ID: <878th06t18.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch> <1506464764-12699-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57924 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752792AbdI0PxE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 11:53:04 -0400
In-Reply-To: <1506464764-12699-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> When testing if a VLAN is one more than one bridge, we print an error
> message that the VLAN is already in use somewhere else. Print both the
> new port which would like the VLAN, and the port which already has it,
> to aid debugging.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
