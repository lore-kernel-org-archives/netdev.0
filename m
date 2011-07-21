From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] bnx2x: Fixed ethtool -d for 578xx
Date: Thu, 21 Jul 2011 13:01:18 -0700 (PDT)
Message-ID: <20110721.130118.1870436438287599332.davem@davemloft.net>
References: <201107212057.24427.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org, ariele@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002Ab1GUUBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 16:01:19 -0400
In-Reply-To: <201107212057.24427.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vlad Zolotarov" <vladz@broadcom.com>
Date: Thu, 21 Jul 2011 20:57:23 +0300

> Registers dump code erroneously treated 578xx as 57712.
> This patch fixes the above and also removes unused data 
> structures.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
