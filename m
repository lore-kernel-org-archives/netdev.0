From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] be2net: patch-set
Date: Thu, 14 May 2015 12:22:16 -0400 (EDT)
Message-ID: <20150514.122216.1032819028084043266.davem@davemloft.net>
References: <1431502214-11810-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933566AbbENQWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 12:22:20 -0400
In-Reply-To: <1431502214-11810-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Date: Wed, 13 May 2015 13:00:11 +0530

> The following patch set has one new feature addition and two fixes.
> 
> Patch 1 adds support for hwmon sysfs interface to display board temperature.
> Board temperature display through ethtool statistics is removed.
> 
> Patch 2 reports "link down" in a few more error cases which are not handled
> currently.
> 
> Patch 3 adds support for os2bmc. OS2BMC feature will allow the server to
> communicate with the on-board BMC/idrac (Baseboard Management Controller)
> over the LOM via standard Ethernet. More details are added in the commit log.
> 
> Please review.

Series applied, thanks.
