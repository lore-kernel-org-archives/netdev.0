From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] tg3: Set 10_100_ONLY flag for additional
 10/100 Mbps devices
Date: Wed, 14 Nov 2012 22:05:09 -0500 (EST)
Message-ID: <20121114.220509.1786209235282358723.davem@davemloft.net>
References: <1352940269-23821-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945909Ab2KODFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 22:05:11 -0500
In-Reply-To: <1352940269-23821-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 14 Nov 2012 16:44:26 -0800

> From: Nithin Nayak Sujir <nsujir@broadcom.com>
> 
> - Also refactor the conditional to use the existing tg3_pci_tbl array.
> - Set flags in the driver_data field of the pci_device_id structure to
> identify these devices.
> - Add PCI_DEVICE_SUB() to pci.h to declare PCI 4-part IDs to match these
> devices.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
