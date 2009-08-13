From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: Add ftracer to help optimize process
 scheduling based on incomming frame allocations
Date: Wed, 12 Aug 2009 22:15:15 -0700 (PDT)
Message-ID: <20090812.221515.147337283.davem@davemloft.net>
References: <20090807202130.GA26677@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rostedt@goodmis.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37325
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751657AbZHMFPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 01:15:05 -0400
In-Reply-To: <20090807202130.GA26677@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 7 Aug 2009 16:21:30 -0400

> Tested by me, working well, applies against the head of the net-next tree
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

For some reason they don't apply cleanly to net-next-2.6, probably
because of the net-2.6 merge I did recently.

Neil, could you please respin, and also could you please not
use the same subject line for all 3 patches?  That becomes the
commit message header, and it should be unique for each patch
since each patch does something different. :)


