From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] [BNX2]: Add EEH PCI recovery
Date: Fri, 16 May 2008 22:18:29 -0700 (PDT)
Message-ID: <20080516.221829.140821513.davem@davemloft.net>
References: <1210973399.5507.18.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, benli@broadcom.com,
	wendyx@us.ibm.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46931
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751430AbYEQFSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 01:18:34 -0400
In-Reply-To: <1210973399.5507.18.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 16 May 2008 14:29:59 -0700

> [BNX2]: Add EEH PCI recovery.
> 
> Add PCI recovery functions to the driver.  The initial pci state is
> also saved so the the MSI state can be restored during PCI recovery.
> 
> Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
