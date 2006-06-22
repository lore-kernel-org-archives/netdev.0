From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Memory corruption in 8390.c ?
Date: Thu, 22 Jun 2006 14:10:43 +0100
Message-ID: <1150981843.15275.163.camel@localhost.localdomain>
References: <20060622023029.GA6156@gondor.apana.org.au>
	 <20060622.012609.25474139.davem@davemloft.net>
	 <20060622083037.GB26083@gondor.apana.org.au>
	 <20060622.013440.97293561.davem@davemloft.net>
	 <1150976063.15275.146.camel@localhost.localdomain>
	 <1150976016.3120.19.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	snakebyte@gmx.de, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:54479 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1751783AbWFVMz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 08:55:29 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1150976016.3120.19.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Iau, 2006-06-22 am 13:33 +0200, ysgrifennodd Arjan van de Ven:
> > The 8390 change (corrected version) also makes 8390.c faster so should
> > be applied anyway, 
> 
> 8390 is such a race monster that a few cycles matter a lot! :-)

There are generic 8390 clones for 100Mbit. I'm not suggesting its a good
idea but people did it.

Alan

