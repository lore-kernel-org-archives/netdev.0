From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 2/3][ROUTE] Clean up proc files creation
Date: Wed, 05 Dec 2007 21:14:36 -0800 (PST)
Message-ID: <20071205.211436.173198786.davem@davemloft.net>
References: <4756DA9F.4000200@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45941
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751378AbXLFFOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 00:14:37 -0500
In-Reply-To: <4756DA9F.4000200@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 05 Dec 2007 20:06:39 +0300

> The rt_cache, stats/rt_cache and rt_acct(optional) files
> creation looks a bit messy. Clean this out and join them
> to other proc-related functions under the proper ifdef.
> 
> The struct net * argument in a new function will help net 
> namespaces patches look nicer.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
