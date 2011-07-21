From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/5] bnx2x: Parity errors recovery for 578xx
Date: Thu, 21 Jul 2011 13:01:32 -0700 (PDT)
Message-ID: <20110721.130132.31907770966780284.davem@davemloft.net>
References: <201107212058.36462.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118Ab1GUUBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 16:01:34 -0400
In-Reply-To: <201107212058.36462.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vlad Zolotarov" <vladz@broadcom.com>
Date: Thu, 21 Jul 2011 20:58:36 +0300

> Fix the parity errors recovery flow for 578xx:
>     - Add a separate column for the 578xx in the parity mask
>       registers DB.
>     - Fix the bnx2x_process_kill_chip_reset() to handle the blocks
>       newly introduced in the 578xx.
> 
> Cover ATC and PGLUE_B blocks for 57712 and 578xx.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
