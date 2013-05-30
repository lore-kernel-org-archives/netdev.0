From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] netxen_nic: Code cleanup and enhancements
Date: Thu, 30 May 2013 16:53:16 -0700 (PDT)
Message-ID: <20130530.165316.1509099384783499212.davem@davemloft.net>
References: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab3E3XxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 19:53:17 -0400
In-Reply-To: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Thu, 30 May 2013 15:51:33 -0400

> This patch series includes following changes:
> 
> * Log driver version information with firmware version information.
> * Log "Unknown" adapter name and serial number in case of
>   mismatched adapter type.
> * netxen_setup_intr() function code cleanup and changes to avoid attaching
>   of multiple pci functions on an adapter with mixed interrupts mode
>   [MSI-X/MSI + INTx].
> 
> Please apply this series to net-next.

Series applied, thanks.
