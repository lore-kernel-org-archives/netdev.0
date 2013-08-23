From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next 06/16] sfc: Introduce and use
 MCDI_DECLARE_BUF macro
Date: Fri, 23 Aug 2013 11:00:19 -0700 (PDT)
Message-ID: <20130823.110019.1381689459905978877.davem@davemloft.net>
References: <1377199609.1703.55.camel@bwh-desktop.uk.level5networks.com>
	<20130822.220236.2202751653391527307.davem@davemloft.net>
	<1377253570.2586.15.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755730Ab3HWSAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 14:00:21 -0400
In-Reply-To: <1377253570.2586.15.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 23 Aug 2013 11:26:10 +0100

> My intent was to separate refactoring changes with no immediate effect
> (#6-9) from functional changes (#10-11), making them easier to review.
> The alignment gets fixed by #11.

Ok I didn't see that, I'll keep reviewing this series then.

Thanks.
