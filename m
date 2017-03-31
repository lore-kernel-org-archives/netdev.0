From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Fri, 31 Mar 2017 15:52:07 +0200
Message-ID: <20170331135207.GG22609@lunn.ch>
References: <e019331d-7050-ca6d-7f27-73878e290f7a@gmail.com>
 <1490821714.3177.189.camel@kernel.crashing.org>
 <1490834778.3177.197.camel@kernel.crashing.org>
 <20170329.201517.300684629549047939.davem@davemloft.net>
 <1490954367.3177.236.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41770 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933000AbdCaNwN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 09:52:13 -0400
Content-Disposition: inline
In-Reply-To: <1490954367.3177.236.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We're running some more testing tonight, if it's all solid I'll shoot
> it out tomorrow or sunday. Dave, it's ok to just spam the list with a
> 55 patches series like that ?

Hi Ben

Is there a good reason to spam the list with 55 patches? The patches
should be incremental, so getting them reviewed and applied in batches
of 10 should not be a problem.

   Andrew
