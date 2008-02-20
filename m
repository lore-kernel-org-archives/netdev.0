From: David Miller <davem@davemloft.net>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Wed, 20 Feb 2008 00:14:50 -0800 (PST)
Message-ID: <20080220.001450.132579707.davem@davemloft.net>
References: <47BA87F0.1050709@cosmosbay.com>
	<1203491081.3248.60.camel@ymzhang>
	<47BBD8E9.2090700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, Valdis.Kletnieks@vt.edu,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752381AbYBTION (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 03:14:13 -0500
In-Reply-To: <47BBD8E9.2090700@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 20 Feb 2008 08:38:17 +0100

> Thanks very much Yanmin, I think we can apply your patch as is, if no 
> regression was found for 32bits.

Great.  Can I get a resubmission of the patch with a cleaned up
changelog entry that describes in the regression along with the
changelog bits I saw in the most recent version of the patch?

An explicit "Acked-by:" from Eric would be nice too :-)

Thanks!
