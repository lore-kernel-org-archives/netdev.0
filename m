From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 00/12] amd-xgbe: AMD XGBE driver updates
 2015-01-16
Date: Fri, 16 Jan 2015 22:27:49 -0500 (EST)
Message-ID: <20150116.222749.373115489946039715.davem@davemloft.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbbAQD1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 22:27:54 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 16 Jan 2015 12:46:18 -0600

> The following series of patches includes functional updates to the
> driver as well as some trivial changes.
> 
> - Fix checks/warnings from checkpatch in the amd-xgbe driver
> - Fix checks/warnings from checkpatch in the amd-xgbe-phy driver
> - Add a check to be sure that the amd-xgbe driver is using the
>   amd-xgbe-phy driver
> - Use a saved control register value when bringing the PCS out of
>   suspend
> - Clear all device state during a device restart
> - Simplify the Rx descriptor ring tracking
> - Remove the need for Tx path spinlocks
> - Update the auto-negotiation logic to make use of the auto-negotiation
>   interrupt
> - Properly support/advertise the FEC capability of the device
> - Use the proper page registers during auto-negotiation extended next
>   page exchange
> - Add ACPI support to the amd-xgbe and amd-xgbe-phy drivers
> - Allow platform specific phy settings to be supplied by UEFI
>   
> This patch series is based on net-next.

Series applied, thanks Tom.
