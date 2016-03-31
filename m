From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: usb: cdc_ncm: adding Telit LE910 V2 mobile
 broadband card
Date: Thu, 31 Mar 2016 16:51:38 -0400 (EDT)
Message-ID: <20160331.165138.1846092223088368562.davem@davemloft.net>
References: <1459430207-11757-1-git-send-email-dnlplm@gmail.com>
	<1459430207-11757-2-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org, bjorn@mork.no
To: dnlplm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932260AbcCaUvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 16:51:45 -0400
In-Reply-To: <1459430207-11757-2-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Palmas <dnlplm@gmail.com>
Date: Thu, 31 Mar 2016 15:16:47 +0200

> Telit LE910 V2 is a mobile broadband card with no ARP capabilities:
> the patch makes this device to use wwan_noarp_info struct
> 
> Signed-off-by: Daniele Palmas <dnlplm@gmail.com>

Bjorn, can you take a quick look at this?

Thank you.
