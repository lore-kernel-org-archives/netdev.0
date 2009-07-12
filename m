From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: restore MTU change operation
Date: Sun, 12 Jul 2009 14:21:23 -0700 (PDT)
Message-ID: <20090712.142123.77201160.davem@davemloft.net>
References: <1247198254.21924.132.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38254
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753203AbZGLVVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 17:21:19 -0400
In-Reply-To: <1247198254.21924.132.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 10 Jul 2009 04:57:34 +0100

> alloc_etherdev() used to install a default implementation of this
> operation, but it must now be explicitly installed in struct
> net_device_ops.

Applied, thanks Ben!
