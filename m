From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] [IPV6]: Consolidate common SNMP code
Date: Tue, 24 Apr 2007 21:54:29 -0700 (PDT)
Message-ID: <20070424.215429.42460618.davem@davemloft.net>
References: <20070425040409.GA4807@gondor.apana.org.au>
	<20070425040637.GA4838@gondor.apana.org.au>
	<20070425.132103.129791594.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52701
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161606AbXDYEyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 00:54:22 -0400
In-Reply-To: <20070425.132103.129791594.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 25 Apr 2007 13:21:03 +0900 (JST)

> In article <20070425040637.GA4838@gondor.apana.org.au> (at Wed, 25 Apr 2007 14:06:37 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> 
> > Hi:
> > 
> > [IPV6]: Consolidate common SNMP code
> > 
> > This patch moves the non-proc SNMP code into addrconf.c and reuses
> > IPv4 SNMP code where applicable.
> :
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Also applied, thanks.
