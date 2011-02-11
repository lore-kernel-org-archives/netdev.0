From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Net driver fixes related to power management
Date: Fri, 11 Feb 2011 11:39:04 -0800 (PST)
Message-ID: <20110211.113904.28807180.davem@davemloft.net>
References: <201102101751.56508.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com,
	linux-pm@lists.linux-foundation.org, thomas@fjellstrom.ca,
	jcliburn@gmail.com, chris.snook@gmail.com, jie.yang@atheros.com
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55990
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758036Ab1BKTi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 14:38:28 -0500
In-Reply-To: <201102101751.56508.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Thu, 10 Feb 2011 17:51:56 +0100

> The following series of patches fix minor issues related to power management
> in the tg3, alt1 and atl1c drivers.
> 
> [1/3] - tg3: Don't use device_init_wakeup() (PCI does that)
> [2/3] - atl1c: Don't use device_init_wakeup() (ditto)
> [3/3] - atl1: Don't use legacy PCI power management.
> 
> Please consider for applying.

All applied to net-next-2.6, thank you.
