From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: properly disconnect the slave PHYs
Date: Tue, 18 Oct 2016 15:24:13 +0200
Message-ID: <20161018132413.GU26778@lunn.ch>
References: <1476792760-60356-1-git-send-email-john@phrozen.org>
 <20161018122909.GR26778@lunn.ch>
 <a310cfb9-8000-3906-242e-501900d5c8a0@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47853 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754454AbcJRNYV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 09:24:21 -0400
Content-Disposition: inline
In-Reply-To: <a310cfb9-8000-3906-242e-501900d5c8a0@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Andrew
> 
> i am testing on v4.4 which did not have a phy_disconnect() call. this
> seems to have been fixed by cda5c15b so please ignore this patch

Hi John

All patches must be against net-next, or net if it is a fix. Anything
else is wrong....

     Andrew
