From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/3] can: sja1000: misused
 netdev->base_addr and OF platform driver
Date: Mon, 01 Jun 2009 02:54:17 -0700 (PDT)
Message-ID: <20090601.025417.110114881.davem@davemloft.net>
References: <20090530175547.772116783@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754152AbZFAJyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 05:54:17 -0400
In-Reply-To: <20090530175547.772116783@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Sat, 30 May 2009 19:55:47 +0200

> this patch series fixes some minor issues with the initial version of
> the CAN device driver interface, corrects misusing netdev->base_addr and
> adds the OF platform driver for the SJA1000.

All applied to net-next-2.6, thanks!
