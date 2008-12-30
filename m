From: David Miller <davem@davemloft.net>
Subject: Re: [patch] locking, percpu counters: introduce separate lock
 classes
Date: Mon, 29 Dec 2008 22:39:45 -0800 (PST)
Message-ID: <20081229.223945.149941966.davem@davemloft.net>
References: <20081229141417.GA1493@elte.hu>
	<20081230035815.GA16454@gondor.apana.org.au>
	<20081230060536.GG11037@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, a.p.zijlstra@chello.nl,
	emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751166AbYL3Gjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 01:39:43 -0500
In-Reply-To: <20081230060536.GG11037@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 30 Dec 2008 07:05:36 +0100

> One small nit: could you please add the Reported-by line for Jeff Kirscher 
> who reported the problem originally:
> 
>  Reported-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I'll make sure to add that to the commit message after
you successfully test Herbert's patch.

Thanks.
