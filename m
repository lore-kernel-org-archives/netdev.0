From: David Miller <davem@davemloft.net>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 15:47:01 -0700 (PDT)
Message-ID: <20090416.154701.21872281.davem@davemloft.net>
References: <alpine.DEB.1.10.0904161504090.15835@qirst.com>
	<49E786FE.6090304@cosmosbay.com>
	<alpine.DEB.1.10.0904161532350.22449@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46935
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754619AbZDPWrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 18:47:10 -0400
In-Reply-To: <alpine.DEB.1.10.0904161532350.22449@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Date: Thu, 16 Apr 2009 15:33:06 -0400 (EDT)

> On Thu, 16 Apr 2009, Eric Dumazet wrote:
> 
>> When you perform your test, you upgrade kernels of both machines ?
> 
> Yes. Both machines always run the same kernel version.

It's good to change multiple variables at a time between
tests...

More seriously, it's going to be hard to isolate anything
unless you concern yourself with changes to one thing
on one system at a time.
