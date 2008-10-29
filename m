From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove NIP6(), NIP6_FMT, NIP6_SEQFMT and final
 users
Date: Tue, 28 Oct 2008 22:39:00 -0700 (PDT)
Message-ID: <20081028.223900.105206094.davem@davemloft.net>
References: <1225223616.11483.40.camel@brick>
	<20081028.160612.90419792.davem@davemloft.net>
	<1225235950.11483.66.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49439
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751918AbYJ2FjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 01:39:23 -0400
In-Reply-To: <1225235950.11483.66.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Tue, 28 Oct 2008 16:19:10 -0700

> Open code NIP6_FMT in the one call inside sscanf and one user
> of NIP6() that could use %p6 in the netfilter code.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks!
