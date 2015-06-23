From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] drivers/net: remove all references to obsolete
 Ethernet-HOWTO
Date: Tue, 23 Jun 2015 06:51:03 -0700 (PDT)
Message-ID: <20150623.065103.1947570113230408149.davem@davemloft.net>
References: <1434918482-22874-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904AbbFWNjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:39:13 -0400
In-Reply-To: <1434918482-22874-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 21 Jun 2015 16:28:02 -0400

> This howto made sense in the 1990s when users had to manually configure
> ISA cards with jumpers or vendor utilities, but with the implementation
> of PCI it became increasingly less and less relevant, to the point where
> it has been well over a decade since I last updated it.  And there is
> no value in anyone else taking over updating it either.
> 
> However the references to it continue to spread as boiler plate text
> from one Kconfig file into the next.  We are not doing end users any
> favours by pointing them at this old document, so lets kill it with
> fire, once and for all, to hopefully stop any further spread.
> 
> No code is changed in this commit, just Kconfig help text.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
