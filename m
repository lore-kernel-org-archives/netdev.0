From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: Log only PHY state transitions
Date: Mon, 31 Jul 2017 16:21:52 -0700 (PDT)
Message-ID: <20170731.162152.1057285339959641588.davem@davemloft.net>
References: <8fc7eb8f-9d64-04c3-a1ca-0cc8eec1ee30@sigmadesigns.com>
        <7a34bf57-4fde-529f-36cf-ad8022185df9@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        slash.tmp@free.fr
To: marc_gonzalez@sigmadesigns.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47336 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751805AbdGaXVz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 19:21:55 -0400
In-Reply-To: <7a34bf57-4fde-529f-36cf-ad8022185df9@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Date: Fri, 28 Jul 2017 13:18:30 +0200

> In the current code, old and new PHY states are always logged.
> From now on, log only PHY state transitions.
> 
> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>

Applied to net-next, thanks.
