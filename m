From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] drivers/isdn: fix sparse warnings
Date: Fri, 27 Feb 2009 01:01:29 -0800 (PST)
Message-ID: <20090227.010129.221180189.davem@davemloft.net>
References: <20090225230737.5377.31370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46250
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754387AbZB0JBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 04:01:45 -0500
In-Reply-To: <20090225230737.5377.31370.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 26 Feb 2009 00:08:20 +0100

> The following series fixes some sparse warnings in drivers/isdn.
> 
> ---
> 
> Hannes Eder (5):
>       drivers/isdn/hardware/eicon: fix sparse warnings: Should it be static?
>       drivers/isdn/hardware/icon: fix sparse warning: cast truncates bits
>       drivers/isdn/hisax: fix sparse warning: Should it be static?
>       drivers/isdn/act2000: fix sparse warning: symbol shadows an earlier one
>       drivers/isdn/capi: fix sparse warning: context imbalance

Applied to net-next-2.6, thanks!
