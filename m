From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: correct kcalloc usage
Date: Thu, 10 Jul 2008 16:51:41 -0700 (PDT)
Message-ID: <20080710.165141.235058998.davem@davemloft.net>
References: <for-27-patch8-1@bga.com>
	<for-27-patch8-2@bga.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.org,
	akpm@linux-foundation.org
To: miltonm@bga.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50126
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752960AbYGJXvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 19:51:41 -0400
In-Reply-To: <for-27-patch8-2@bga.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Milton Miller <miltonm@bga.com>
Date: Thu, 10 Jul 2008 16:25:33 -0500 (CDT)

> kcalloc is supposed to be called with the count as its first argument and
> the element size as the second.
> 
> Signed-off-by: Milton Miller <miltonm@bga.com>

Applied, thanks!
