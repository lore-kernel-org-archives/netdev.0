From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netxen: fix firmware init after resume
Date: Tue, 22 Sep 2009 14:14:28 -0700 (PDT)
Message-ID: <20090922.141428.102797799.davem@davemloft.net>
References: <1253510439-28464-1-git-send-email-dhananjay@netxen.com>
	<1253510439-28464-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750850AbZIVVOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:14:10 -0400
In-Reply-To: <1253510439-28464-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 20 Sep 2009 22:20:39 -0700

> After successful firmware init, return instead of
> falling to error path (leading to detach) after
> resuming to D0 state. This was broken in recent
> firmware reset rehaul.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
