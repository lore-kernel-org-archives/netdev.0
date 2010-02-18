From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net/macvtap: add vhost support
Date: Thu, 18 Feb 2010 14:11:32 -0800 (PST)
Message-ID: <20100218.141132.83865580.davem@davemloft.net>
References: <20100215.215341.66627877.davem@davemloft.net>
	<201002181644.29740.arnd@arndb.de>
	<201002181646.50674.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, kaber@trash.net, eswierk@aristanetworks.com,
	netdev@vger.kernel.org, mst@redhat.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50834
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754783Ab0BRWLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 17:11:17 -0500
In-Reply-To: <201002181646.50674.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 18 Feb 2010 16:46:50 +0100

> This adds support for passing a macvtap file descriptor into
> vhost-net, much like we already do for tun/tap.
> 
> Most of the new code is taken from the respective patch
> in the tun driver and may get consolidated in the future.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
