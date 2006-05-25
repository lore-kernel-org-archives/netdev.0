From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [IrDA] ali-ircc: using device model power
 management
Date: Thu, 25 May 2006 16:21:25 -0700 (PDT)
Message-ID: <20060525.162125.82375049.davem@davemloft.net>
References: <20060525062052.GD24611@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20369
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S965186AbWEYXVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 19:21:20 -0400
To: samuel@sortiz.org
In-Reply-To: <20060525062052.GD24611@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Thu, 25 May 2006 06:20:52 +0000

> This patch gets rid of the old power management code and now uses the
> device model for the ali-ircc driver.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Enhancement, thus applied to net-2.6.18

Thanks.
