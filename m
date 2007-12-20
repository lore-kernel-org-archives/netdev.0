From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] XFRM: Audit function arguments misordered
Date: Thu, 20 Dec 2007 00:01:10 -0800 (PST)
Message-ID: <20071220.000110.188319069.davem@davemloft.net>
References: <20071219192309.15561.9843.stgit@flek.americas.hpqcorp.net>
	<20071219192937.15561.52837.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49970
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751367AbXLTIBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 03:01:14 -0500
In-Reply-To: <20071219192937.15561.52837.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Wed, 19 Dec 2007 14:29:38 -0500

> In several places the arguments to the xfrm_audit_start() function are in the
> wrong order resulting in incorrect user information being reported.  This
> patch corrects this by pacing the arguments in the correct order.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied, thanks for fixing this bug.
