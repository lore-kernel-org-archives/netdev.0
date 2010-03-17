From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Tue, 16 Mar 2010 21:29:17 -0700 (PDT)
Message-ID: <20100316.212917.87886075.davem@davemloft.net>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
	<1268337450-6749-4-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36036
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753007Ab0CQE2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 00:28:54 -0400
In-Reply-To: <1268337450-6749-4-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Thu, 11 Mar 2010 20:57:29 +0100

> `ip -s link` shows interface counters truncated to 32 bit. This is
> because interface statistics are transported only in 32-bit quantity
> to userspace. This commit adds a new IFLA_STATS64 attribute that
> exports them in full 64 bit.
> 
> References: http://lkml.indiana.edu/hypermail/linux/kernel/0307.3/0215.html
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Applied.
