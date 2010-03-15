From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] timestamping: fix example build
Date: Mon, 15 Mar 2010 16:05:12 -0700 (PDT)
Message-ID: <20100315.160512.218598212.davem@davemloft.net>
References: <4B9B214F.4040005@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrick.ohly@intel.com
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42698
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937057Ab0COXEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 19:04:50 -0400
In-Reply-To: <4B9B214F.4040005@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 12 Mar 2010 21:23:27 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix Makefiles so that Documentation/networking/timestamping/timestamping.c
> will build when using the CONFIG_BUILD_DOCSRC kconfig option.
> (timestamping.c does not build currently with its simple Makefile.)
> 
> Also fix printf format warnings.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: Patrick Ohly <patrick.ohly@intel.com>

Applied, thanks Randy.
