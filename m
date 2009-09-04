From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netdev: Remove SIOCDEVPRIVATE aliases for MDIO
 ioctls
Date: Thu, 03 Sep 2009 20:09:36 -0700 (PDT)
Message-ID: <20090903.200936.31182619.davem@davemloft.net>
References: <1252010313.2781.14.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932873AbZIDDJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:09:20 -0400
In-Reply-To: <1252010313.2781.14.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 03 Sep 2009 21:38:33 +0100

> The standard MDIO ioctl numbers are well-established and these should
> no longer be needed.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
