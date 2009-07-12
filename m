From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netdev: restore MAC address set and validate
 operations
Date: Sun, 12 Jul 2009 14:21:13 -0700 (PDT)
Message-ID: <20090712.142113.72693323.davem@davemloft.net>
References: <1247198075.21924.129.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, stable@vger.kernel.org,
	536455@bugs.debian.org, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752754AbZGLVVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 17:21:10 -0400
In-Reply-To: <1247198075.21924.129.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 10 Jul 2009 04:54:35 +0100

> alloc_etherdev() used to install default implementations of these
> operations, but they must now be explicitly installed in struct
> net_device_ops.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
