From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net phylib: Remove unnecessary condition check in
 phy
Date: Wed, 09 Apr 2014 13:04:14 -0400 (EDT)
Message-ID: <20140409.130414.1427995437695377764.davem@davemloft.net>
References: <5344BF99.5090604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933686AbaDIREQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 13:04:16 -0400
In-Reply-To: <5344BF99.5090604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Wed, 09 Apr 2014 09:03:45 +0530

> This condition check makes no difference in the code flow since 3.10
> 
> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
