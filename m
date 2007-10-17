From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: new NAPI interface broken
Date: Wed, 17 Oct 2007 17:26:39 +0200
Message-ID: <OFEAB3A06B.B1A057BE-ONC1257376.005544E2-C1257377.0054C2CB@de.ibm.com>
References: <1192519787.7205.3.camel@pasglop>	 <20071016.004410.85411180.davem@davemloft.net>
	 <1192523336.7205.13.camel@pasglop>	 <20071016.013146.28785302.davem@davemloft.net> <1192525309.7205.16.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: arjan@linux.intel.com, David Miller <davem@davemloft.net>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	ossthema@linux.vnet.ibm.com, shemminger@linux-foundation.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:48128 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761635AbXJQP0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 11:26:43 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9HFQgNm048488
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 15:26:42 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9HFQg1v2244690
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 17:26:42 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9HFQerh008620
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 17:26:41 +0200
In-Reply-To: <1192525309.7205.16.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote on 16.10.2007
11:01:49:

>
>
> Christoph, have any of you tried it on powerpc ?

No we didn't try this (yet).
This approach makes a lot of sense.

Why is this not installed by both large distros on PPC by default?
how mature is this for larger SMPs on PPC?

>
> Cheers,
> Ben.
>
>
Gruss / Regards
Christoph R.


