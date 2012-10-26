From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: remove dead code
Date: Fri, 26 Oct 2012 03:47:11 -0400 (EDT)
Message-ID: <20121026.034711.982156912530541923.davem@davemloft.net>
References: <20121025143031.16991.81337.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756904Ab2JZHrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 03:47:13 -0400
In-Reply-To: <20121025143031.16991.81337.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 25 Oct 2012 15:30:52 +0100

> From: Alan Cox <alan@linux.intel.com>
> 
> multi is assigned to 0 and then acts as a constant. Remove the dead
> code.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied.
