From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netdev: Convert MDIO ioctl implementation to use
 struct mii_ioctl_data
Date: Thu, 03 Sep 2009 20:10:29 -0700 (PDT)
Message-ID: <20090903.201029.82335402.davem@davemloft.net>
References: <1252010477.2781.20.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51033
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932719AbZIDDKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:10:14 -0400
In-Reply-To: <1252010477.2781.20.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 03 Sep 2009 21:41:17 +0100

> A few drivers still access the arguments to MDIO ioctls as an array of
> u16.  Convert them to use struct mii_ioctl_data.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
