From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] dt: emac: document device-tree based phy discovery
 and setup
Date: Tue, 07 Mar 2017 12:15:28 -0800 (PST)
Message-ID: <20170307.121528.441751689674246830.davem@davemloft.net>
References: <cecba35f-0a94-67e8-543a-a1d340d62947@gmail.com>
        <0149985a262cfc2feacd604a581cd5ae9134a525.1488228734.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        ivan@de.ibm.com, f.fainelli@gmail.com, andrew@lunn.ch,
        robh+dt@kernel.org
To: chunkeey@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36252 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933014AbdCGUYd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 15:24:33 -0500
In-Reply-To: <0149985a262cfc2feacd604a581cd5ae9134a525.1488228734.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Lamparter <chunkeey@googlemail.com>
Date: Mon, 27 Feb 2017 21:54:50 +0100

> This patch adds documentation for a new "phy-handle" property,
> "fixed-link" and "mdio" sub-node. These allows the enumeration
> of PHYs which are supported by the phy library under drivers/net/phy.
> 
> The EMAC ethernet controller in IBM and AMCC 4xx chips is
> currently stuck with a few privately defined phy
> implementations. It has no support for PHYs which
> are supported by the generic phylib.
> 
> Acked-by: Rob Herring <robh@kernel.org>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>

Applied, thanks.
