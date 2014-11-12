From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: fix NULL pointer dereference
Date: Wed, 12 Nov 2014 13:51:57 -0500 (EST)
Message-ID: <20141112.135157.2000072047136424701.davem@davemloft.net>
References: <546383B7.2090106@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbaKLSv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 13:51:59 -0500
In-Reply-To: <546383B7.2090106@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Wed, 12 Nov 2014 10:58:47 -0500

> This patch fixes a NULL pointer dereference when __tx_port_find() doesn't
> find a matching port.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Applied, thanks.
