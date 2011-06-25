From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 40/72] spider_net: Move the spider_net (IBM) driver
Date: Sat, 25 Jun 2011 16:34:39 +0200
Message-ID: <201106251634.40126.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-41-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Utz Bacher <utz.bacher@de.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:64457 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740Ab1FYOe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 10:34:56 -0400
In-Reply-To: <1309010363-22750-41-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Jeff Kirsher wrote:
> Move the spider_net (IBM) driver into drivers/net/ethernet/ibm/ and
> make the necessary Kconfig and Makefile changes
> 
> CC: Utz Bacher <utz.bacher@de.ibm.com>
> CC: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
> CC: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

spider_net is not an IBM product, we just wrote the driver. The
chip was made by Toshiba, and they are also maintaining the driver
now.

	Arnd
