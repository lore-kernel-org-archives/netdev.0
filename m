From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: allow one link per bearer to
 neighboring nodes
Date: Sun, 16 Nov 2014 14:27:32 -0500 (EST)
Message-ID: <20141116.142732.2229848248645548063.davem@davemloft.net>
References: <1415986399-23874-1-git-send-email-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	erik.hugne@ericsson.com, netdev@vger.kernel.org
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbaKPT1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 14:27:35 -0500
In-Reply-To: <1415986399-23874-1-git-send-email-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Fri, 14 Nov 2014 18:33:19 +0100

> There is no reason to limit the amount of possible links to a
> neighboring node to 2. If we have more then two bearers we can also
> establish more links.
> 
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
> Reviewed-By: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
