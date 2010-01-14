From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] lib/vsprintf.c: Add IPV4 options %pI4[hnbl]
 for host, network, big and little endian
Date: Wed, 13 Jan 2010 20:23:39 -0800 (PST)
Message-ID: <20100113.202339.128369196.davem@davemloft.net>
References: <1262680938.1952.17.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752192Ab0ANEXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 23:23:30 -0500
In-Reply-To: <1262680938.1952.17.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 05 Jan 2010 00:42:18 -0800

> This should allow the removal of the #defines and uses
> of NIPQUAD and NIPQUAD_FMT
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
