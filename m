From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] qlcnic: Refactoring and enhancements
Date: Tue, 17 Dec 2013 17:10:12 -0500 (EST)
Message-ID: <20131217.171012.18122536773101449.davem@davemloft.net>
References: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab3LQWKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 17:10:13 -0500
In-Reply-To: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Tue, 17 Dec 2013 09:01:48 -0500

> This patch series includes follwing changes
> 
> * Refactor DCBX code. Do not allow DCBX operations for VFs
> * Issue INIT_NIC mailbox command only once
> * Refactor initialize nic code path
> * Allow configuration for single TX/RX queue
> * VLAN enhancement for 84xx adapters
> * Support for 16 virtual NIC functions for 84XX series adapters
> 
> Please apply to net-next

Series applied, thanks.
