From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7][ATM]: [lanai] change VENDOR to DEVICE
Date: Mon, 16 Jul 2007 18:33:37 -0700 (PDT)
Message-ID: <20070716.183337.123974481.davem@davemloft.net>
References: <200707161630.l6GGUtEq009321@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38434
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754455AbXGQBde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:33:34 -0400
In-Reply-To: <200707161630.l6GGUtEq009321@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Mon, 16 Jul 2007 12:30:55 -0400

> [ATM]: [lanai] change VENDOR to DEVICE
> 
> There were 2 bad named macros in pci_ids (LANAI 2 and IHB). Rename it to
> DEVICE, because it's device id. Also some cleanup in the pci_device_id
> table (use PCI_VDEVICE).
> 
> Cc: Mitchell Blank Jr <mitch@sfgoth.com>
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Signed-off-by: chas williams <chas@cmf.nrl.navy.mil>

This patch is already applied.

Because of this and the sch_atm.c rejects, I guess you're
not generating these patches against Linus's current tree.
