From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] IPV4: route inline changes
Date: Thu, 10 Apr 2008 01:53:04 -0700 (PDT)
Message-ID: <20080410.015304.209498891.davem@davemloft.net>
References: <20080401004708.009204033@vyatta.com>
	<20080401004724.677182853@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752480AbYDJIxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 04:53:03 -0400
In-Reply-To: <20080401004724.677182853@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 31 Mar 2008 17:47:12 -0700

> Don't mark functions that are large as inline, let compiler decide.
> Also, use inline rather than __inline__.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6.26, thanks!
