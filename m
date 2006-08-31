From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rate limiting for socket allocation failure messages
Date: Thu, 31 Aug 2006 15:22:02 -0700 (PDT)
Message-ID: <20060831.152202.112833372.davem@davemloft.net>
References: <20060831095921.GA13845@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7400
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932459AbWHaWV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:21:56 -0400
To: mita@miraclelinux.com
In-Reply-To: <20060831095921.GA13845@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Akinobu Mita <mita@miraclelinux.com>
Date: Thu, 31 Aug 2006 18:59:21 +0900

> (Resending due to local mail server trouble)
> 
> This patch limits the warning messages when socket allocation
> failures happen. It happens under memory pressure.
> 
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Akinobu Mita <mita@miraclelinux.com>

Patch applied, thanks a lot.
