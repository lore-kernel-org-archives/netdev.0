From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax25: Fix missing break
Date: Mon, 16 Jul 2012 23:22:54 -0700 (PDT)
Message-ID: <20120716.232254.720684737816173031.davem@davemloft.net>
References: <20120713163247.22674.82793.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab2GQGWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:22:55 -0400
In-Reply-To: <20120713163247.22674.82793.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 13 Jul 2012 17:33:08 +0100

> From: Alan Cox <alan@linux.intel.com>
> 
> At least there seems to be no reason to disallow ROSE sockets when
> NETROM is loaded.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied, thanks Alan.
