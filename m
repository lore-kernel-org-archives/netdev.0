From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sched: remove unused backlog in RED stats
Date: Wed, 12 Jan 2011 19:00:47 -0800 (PST)
Message-ID: <20110112.190047.38302648.davem@davemloft.net>
References: <20110112174232.05d9429d@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34838
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932538Ab1AMDAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 22:00:14 -0500
In-Reply-To: <20110112174232.05d9429d@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 12 Jan 2011 17:42:32 -0800

> The RED statistics structure includes backlog field which is not
> set or used by any code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
