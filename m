From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] bnx2x: Read FIP mac from SHMEM in single
 function mode
Date: Thu, 21 Jul 2011 13:01:26 -0700 (PDT)
Message-ID: <20110721.130126.778046001730863055.davem@davemloft.net>
References: <201107212057.52485.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab1GUUB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 16:01:27 -0400
In-Reply-To: <201107212057.52485.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vlad Zolotarov" <vladz@broadcom.com>
Date: Thu, 21 Jul 2011 20:57:52 +0300

> Read FIP MAC address from SHMEM's "port" section
> similar to what we do in a MF mode when we read it from 
> a "func" section of SHMEM.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
