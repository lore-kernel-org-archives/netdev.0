From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: sanitise overlong driver information strings
Date: Sun, 17 Jun 2012 16:20:42 -0700 (PDT)
Message-ID: <20120617.162042.780712129528156373.davem@davemloft.net>
References: <1339672722-22793-1-git-send-email-phil.sutter@viprinet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil.sutter@viprinet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab2FQXUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:20:43 -0400
In-Reply-To: <1339672722-22793-1-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil.sutter@viprinet.com>
Date: Thu, 14 Jun 2012 13:18:42 +0200

> As seen on smsc75xx, driver_info->description being longer than 32
> characters messes up 'ethtool -i' output.
> 
> Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>

Applied.
