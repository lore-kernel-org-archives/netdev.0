From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/6] net: dsa: mv88e6xxx: Move mv88e6xxx_port_db_load_purge()
Date: Wed, 27 Sep 2017 11:51:32 -0400
Message-ID: <8760c46sxn.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch> <1506464764-12699-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58056 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752877AbdI0PzL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 11:55:11 -0400
In-Reply-To: <1506464764-12699-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> This function is going to be needed by a soon to be added new
> function. Move it earlier so we can avoid a forward declaration.
> No code changes.

s/code/functional/

> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
