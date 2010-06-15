From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Revert incorrect indentation changes
Date: Mon, 14 Jun 2010 23:13:41 -0700 (PDT)
Message-ID: <20100614.231341.183052688.davem@davemloft.net>
References: <1276541606.2074.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chavey@google.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35922
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751946Ab0FOGN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 02:13:29 -0400
In-Reply-To: <1276541606.2074.12.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 14 Jun 2010 19:53:26 +0100

> commit 97f8aefbbfb5aa5c9944e5fa8149f1fdaf71c7b6 "net: fix ethtool
> coding style errors and warnings" changed the indentation of several
> macro definitions in ethtool.h.  These definitions line up in the diff
> where there is an extra character at the start of each line, but not
> in the resulting file.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
