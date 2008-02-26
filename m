From: David Miller <davem@davemloft.net>
Subject: Re: include/linux/pcounter.h
Date: Tue, 26 Feb 2008 13:35:31 -0800 (PST)
Message-ID: <20080226.133531.69481052.davem@davemloft.net>
References: <20080216112618.ec450f9b.akpm@linux-foundation.org>
	<20080216.215401.20463603.davem@davemloft.net>
	<20080226092454.GA10987@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, dada1@cosmosbay.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49895
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762396AbYBZVeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 16:34:46 -0500
In-Reply-To: <20080226092454.GA10987@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 26 Feb 2008 10:24:54 +0100

> but the main and fundamental question still remains unanswered (more 
> than 3 weeks after Andrew asked that question): why was this piece of 
> general infrastructure merged via net.git and not submitted to lkml 
> ever? The code touching -mm does _not_ count as "review".

I already stated this was a mistake and it won't happen
again in the future.

And if you ask Andrew, he'll tell you I've been hard on
my network developers about this lately.
