From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 2/2] net: phy: at803x: Change error to EINVAL for
 invalid MAC
Date: Wed, 11 Oct 2017 14:14:54 -0700 (PDT)
Message-ID: <20171011.141454.1668106904505922160.davem@davemloft.net>
References: <20171010174256.21930-1-dmurphy@ti.com>
        <20171010174256.21930-2-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        Woojung.Huh@microchip.com, afd@ti.com
To: dmurphy@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752485AbdJKVOz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:14:55 -0400
In-Reply-To: <20171010174256.21930-2-dmurphy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Murphy <dmurphy@ti.com>
Date: Tue, 10 Oct 2017 12:42:56 -0500

> Change the return error code to EINVAL if the MAC
> address is not valid in the set_wol function.
> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>

Applied to net-next.
