From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 0/5] Interrupt support for mv88e6xxx
Date: Tue, 18 Oct 2016 20:57:29 +0200
Message-ID: <20161018185729.GB15180@lunn.ch>
References: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
 <87r37dlccl.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48196 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754279AbcJRS5g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 14:57:36 -0400
Content-Disposition: inline
In-Reply-To: <87r37dlccl.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> mv88e6xxx_g1_* should've been moved to global1.c, I'll move them later.

Hi Vivian

I did consider that, but at the moment, there are only access
functions in there. But the code should be easy to move.

	  Andrew
