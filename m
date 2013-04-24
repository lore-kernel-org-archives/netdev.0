From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] qlcnic: Driver updates
Date: Wed, 24 Apr 2013 19:36:42 -0400 (EDT)
Message-ID: <20130424.193642.2229455137240542878.davem@davemloft.net>
References: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	shahed.shaikh@qlogic.com, Dept_NX_Linux_NIC_Driver@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758537Ab3DXXgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:36:46 -0400
In-Reply-To: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Wed, 24 Apr 2013 18:42:38 -0400

> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> This set of patches has following updates:
> * Enhanced channel configuration logs by adding logs for various cases.
> * Take EPORT out of reset before disabling pause frame generation in the
>   adapter.
> * Add eSwitch statistics support in ethtool stats.
> * Enable interrupt coalescing for 83xx adapter.
> * Rename IRQ description.
> * Added PCI_VENDOR_ID_QLOGIC, PCI_DEVICE_ID_QLOGIC_834X and PCI_DEVICE_ID_QLOGIC_824X
>   for the patch "qlcnic: Add identifying string for 83xx adapter" as per Francois comment.  
> 
> Please apply to net-next.

Series applied, thanks.
