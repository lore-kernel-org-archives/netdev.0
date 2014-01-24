From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] qlcnic: Refactoring and enhancements for
 all adapters.
Date: Thu, 23 Jan 2014 16:14:37 -0800 (PST)
Message-ID: <20140123.161437.1632835743136251770.davem@davemloft.net>
References: <cover.1390491376.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbaAXAOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:14:38 -0500
In-Reply-To: <cover.1390491376.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Thu, 23 Jan 2014 17:18:27 -0500

> This patch series contains following patches.
> 
> o Enhanced debug data collection when we are in Tx-timeout situation.
> o Enhanced MSI-x vector calculation for defualt load path as well
>   as for TSS/RSS ring change path.
> o Refactored interrupt coalescing code for all adapters.
> o Refactored interrupt handling as well as cleanup of poll controller
>   code patch for all adapters.
> o changed rx_mac_learn type to boolean.
> 
> Please apply to net-next.

Series applied, thanks.
