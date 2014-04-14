From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] qlcnic: Bug fixes
Date: Mon, 14 Apr 2014 13:44:18 -0400 (EDT)
Message-ID: <20140414.134418.637047134028618012.davem@davemloft.net>
References: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220AbaDNRoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 13:44:20 -0400
In-Reply-To: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Mon, 14 Apr 2014 10:02:17 -0400

> This patch series contains following bug fixes -
> 
> * Send INIT_NIC_FUNC mailbox command as first mailbox
> * Fix a panic because of uninitialized delayed_work.
> * Fix inconsistent calculation of max rings count.
> * Fix PVID configuration issue. Driver needs to clear older
>   PVID before adding new one.
> * Fix QLogic application/driver interface by packing vNIC information
>   array.
> * Fix a crash when user tries to disable SR-IOV while VFs are
>   still assigned to VMs.
> 
> Please apply to net.

Series applied, thank you.
