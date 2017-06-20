From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 2/2] net-next: mt7530: add nh and proto offsets to the ops
 struct
Date: Tue, 20 Jun 2017 20:02:31 +0200
Message-ID: <20170620180231.GD12383@lunn.ch>
References: <20170620080655.7251-1-john@phrozen.org>
 <20170620080655.7251-2-john@phrozen.org>
 <20170620135439.GA12383@lunn.ch>
 <0c30b590-19b1-8648-eea1-943724c60941@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57522 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750927AbdFTSCx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 14:02:53 -0400
Content-Disposition: inline
In-Reply-To: <0c30b590-19b1-8648-eea1-943724c60941@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> #include "../dsa/dsa_priv.h"
> 
> I was not sure if this is ok or if we would need to move the struct
> definition to include/net/dsa.h in that case

Hi John

Please move the structure.

       Andrew
