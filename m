From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net/ethtool: Add support for the ethtool
 feature to flash firmware image from a specified file.
Date: Wed, 02 Sep 2009 23:10:07 -0700 (PDT)
Message-ID: <20090902.231007.117713606.davem@davemloft.net>
References: <20090903030241.GA19390@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41285
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754452AbZICGJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 02:09:52 -0400
In-Reply-To: <20090903030241.GA19390@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Thu, 3 Sep 2009 08:32:55 +0530

> This patch adds support to flash a firmware image to a device using ethtool.
> The driver gets the filename of the firmware image and flashes the image
> using the request firmware path.
> 
> The region "on the chip" to be flashed can be specified by an option.
> It is upto the device driver to enumerate the region number passed by ethtool,
> to the region to be flashed.
> 
> The default behavior is to flash all the regions on the chip.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied to net-next-2.6, thanks.
