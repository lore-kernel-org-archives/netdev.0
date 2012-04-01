From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: dont overwrite settings for PHY Quick link
Date: Sun, 01 Apr 2012 16:11:04 -0400 (EDT)
Message-ID: <20120401.161104.1115073131193072280.davem@davemloft.net>
References: <20120330172859.GB2703@Neptun>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938Ab2DAULJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 16:11:09 -0400
In-Reply-To: <20120330172859.GB2703@Neptun>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Fri, 30 Mar 2012 19:28:59 +0200

> This patch corrects a bug in function sky2_open() of the Marvell Yukon 2 driver
> in which the settings for PHY quick link are overwritten.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Stephen, ping?
