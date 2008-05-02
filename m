From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] [BNX2]: Zero out context memory for 5709.
Date: Fri, 02 May 2008 16:58:50 -0700 (PDT)
Message-ID: <20080502.165850.233995187.davem@davemloft.net>
References: <1209595915.7941.63.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60383
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935580AbYEBX6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:58:50 -0400
In-Reply-To: <1209595915.7941.63.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 30 Apr 2008 15:51:55 -0700

> [BNX2]: Zero out context memory for 5709.
> 
> We should zero out the context memory for 5709 before each reset.  When
> we resume after suspend for example, the memory may not be zero and the
> chip may not function correctly.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
