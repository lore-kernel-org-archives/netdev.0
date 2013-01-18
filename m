From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] net: asix: init ASIX AX88772B MAC from EEPROM
Date: Fri, 18 Jan 2013 14:14:12 -0500 (EST)
Message-ID: <20130118.141412.1498849408295672025.davem@davemloft.net>
References: <1358346247-10579-1-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, oneukum@suse.de,
	christian.riesch@omicron.at, eric.dumazet@gmail.com
To: dev@lynxeye.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab3ARTOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:14:15 -0500
In-Reply-To: <1358346247-10579-1-git-send-email-dev@lynxeye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <dev@lynxeye.de>
Date: Wed, 16 Jan 2013 15:24:06 +0100

> The device comes up with a MAC address of all zeros. We need to read the
> initial device MAC from EEPROM so it can be set properly later.
> 
> Signed-off-by: Lucas Stach <dev@lynxeye.de>

Applied.
