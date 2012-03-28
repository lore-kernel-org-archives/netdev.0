From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] wimax: i2400m-usb - use a private struct
 ethtool_ops
Date: Tue, 27 Mar 2012 22:30:35 -0400 (EDT)
Message-ID: <20120327.223035.737966483387610866.davem@davemloft.net>
References: <1332761036-8913-1-git-send-email-phil.sutter@viprinet.com>
	<1332761036-8913-2-git-send-email-phil.sutter@viprinet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, inaky.perez-gonzalez@intel.com
To: phil.sutter@viprinet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757250Ab2C1Cai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:30:38 -0400
In-Reply-To: <1332761036-8913-2-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil.sutter@viprinet.com>
Date: Mon, 26 Mar 2012 13:23:56 +0200

> This way the USB variant of the driver uses usb_make_path in order to
> provide bus-info compatible to other USB drivers (like e.g. asix.c).
> 
> Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>

Applied.
