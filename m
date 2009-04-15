From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying to
 ifenslave a second interface to my bond
Date: Tue, 14 Apr 2009 20:23:09 -0700 (PDT)
Message-ID: <20090414.202309.01722171.davem@davemloft.net>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com>
	<11276.1239757967@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@mad-scientist.net, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46956
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752420AbZDODXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 23:23:18 -0400
In-Reply-To: <11276.1239757967@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 14 Apr 2009 18:12:47 -0700

> 	I think I know what's going on.  I believe this patch will
> resolve things, but I won't be able to test it until tomorrow.  If you
> want to test this, great; if you want to wait, that's fine too.

Jay, thanks for working on this.

Let me know when you have a final version of this fix for me
to include.
