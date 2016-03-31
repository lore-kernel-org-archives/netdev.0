From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] net: dsa: mv88e6xxx: Introduce
 _mv88e6xxx_phy_page_{read,write}
Date: Thu, 31 Mar 2016 15:13:08 -0400 (EDT)
Message-ID: <20160331.151308.1637649061289212189.davem@davemloft.net>
References: <1459301981-26535-1-git-send-email-patrick@puiterwijk.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, netdev@vger.kernel.org, dennis@ausil.us,
	pbrobinson@gmail.com
To: patrick@puiterwijk.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbcCaTNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:13:14 -0400
In-Reply-To: <1459301981-26535-1-git-send-email-patrick@puiterwijk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Uiterwijk <patrick@puiterwijk.org>
Date: Wed, 30 Mar 2016 01:39:40 +0000

> Add versions of the phy_page_read and _write functions to
> be used in a context where the SMI mutex is held.
> 
> Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Signed-off-by: Patrick Uiterwijk <patrick@puiterwijk.org>

Applied.
