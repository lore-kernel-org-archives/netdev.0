From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/xfrm/xfrm_state: unexport xfrm_state_mtu
Date: Thu, 29 Jun 2006 13:04:13 -0700 (PDT)
Message-ID: <20060629.130413.00932812.davem@davemloft.net>
References: <20060629192035.GT19712@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40085
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932377AbWF2UEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:04:14 -0400
To: bunk@stusta.de
In-Reply-To: <20060629192035.GT19712@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Thu, 29 Jun 2006 21:20:35 +0200

> This patch removes the unused EXPORT_SYMBOL(xfrm_state_mtu).
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks.
