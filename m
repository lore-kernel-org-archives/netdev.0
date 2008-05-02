From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] [BNX2]: Fix register test on 5709.
Date: Fri, 02 May 2008 16:58:44 -0700 (PDT)
Message-ID: <20080502.165844.89270308.davem@davemloft.net>
References: <1209595898.7941.62.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964841AbYEBX6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:58:44 -0400
In-Reply-To: <1209595898.7941.62.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 30 Apr 2008 15:51:38 -0700

> [BNX2]: Fix register test on 5709.
> 
> The register BNX2_CTX_STATUS (0x1004) should be skipped on 5709 as it
> contains reserved bits.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
