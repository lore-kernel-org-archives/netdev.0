From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] tipc: clean out all instances of #if 0'd
 unused code
Date: Wed, 13 Oct 2010 14:28:34 -0700 (PDT)
Message-ID: <20101013.142834.226768662.davem@davemloft.net>
References: <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
	<20101013162652.GF31379@hmsreliant.think-freely.org>
	<4CB5E79B.4060507@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44954
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751586Ab0JMV2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 17:28:11 -0400
In-Reply-To: <4CB5E79B.4060507@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Wed, 13 Oct 2010 13:08:43 -0400

> This cleanup patch (patch #5) doesn't explicitly depend on
> the other 4 bearer related patches, so it can be applied
> at whatever time is most convenient for Dave.

I've added patch #5 to net-next-2.6, thanks.
