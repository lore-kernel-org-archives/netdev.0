From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbevf: Message formatting fixup
Date: Mon, 22 Mar 2010 20:08:16 -0700 (PDT)
Message-ID: <20100322.200816.218086998.davem@davemloft.net>
References: <201003221759.o2MHxFlh015632@hera.kernel.org>
	<1269285157.22616.55.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43171
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751583Ab0CWDHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 23:07:54 -0400
In-Reply-To: <1269285157.22616.55.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 22 Mar 2010 12:12:37 -0700

> Commit 29b8dd024bd48c3d1d1e5140f5bbb683786f998e
> left a trailing ", " after a message.
> Fix it and make the text used a bit smaller when DEBUG is #defined
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Looks good, applied, thanks Joe.
