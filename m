From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] can: various fixes to the device driver interface
Date: Mon, 20 Jul 2009 12:28:50 -0700 (PDT)
Message-ID: <20090720.122850.248253787.davem@davemloft.net>
References: <20090720140638.342067093@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50189
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752710AbZGTT2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 15:28:45 -0400
In-Reply-To: <20090720140638.342067093@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Mon, 20 Jul 2009 16:06:38 +0200

> this patch series fixes the following issues with CAN device driver
> interface and the SJA1000 driver:
> 
> [PATCH 1/3] can: sja1000: remove duplicated includes
> [PATCH 2/3] can: restart device even if dev_alloc_skb() fails
> [PATCH 3/3] can: switch carrier on if device was stopped while in bus-off state

All applied, thanks.
