From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Remove trailing semicolon in macro definition
Date: Tue, 25 Jul 2017 12:33:54 -0700 (PDT)
Message-ID: <20170725.123354.362507897865464813.davem@davemloft.net>
References: <d1f4d4f1-e60b-6b4d-6f98-3be70da859b5@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        slash.tmp@free.fr
To: marc_gonzalez@sigmadesigns.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60190 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753275AbdGYTdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 15:33:55 -0400
In-Reply-To: <d1f4d4f1-e60b-6b4d-6f98-3be70da859b5@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Date: Tue, 25 Jul 2017 11:08:15 +0200

> Commit e5a03bfd873c2 ("phy: Add an mdio_device structure")
> introduced a spurious trailing semicolon. Remove it.
> 
> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>

Good catch, applied, thanks.
