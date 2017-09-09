From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dt-bindings: net: don't confuse with generic PHY
 property
Date: Fri, 08 Sep 2017 20:50:09 -0700 (PDT)
Message-ID: <20170908.205009.600915514085411624.davem@davemloft.net>
References: <2e201cc1cff4fad372f589c83c4c438b3dccbadf.1504771799.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42820 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753201AbdIIDuK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 23:50:10 -0400
In-Reply-To: <2e201cc1cff4fad372f589c83c4c438b3dccbadf.1504771799.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Thu,  7 Sep 2017 11:09:59 +0300

> This complements commit 9a94b3a4bd (dt-binding: phy: don't confuse with
> Ethernet phy properties).
> 
> The generic PHY 'phys' property sometime appears in the same node with
> the Ethernet PHY 'phy' or 'phy-handle' properties. Add a warning in
> ethernet.txt to reduce confusion.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied.
