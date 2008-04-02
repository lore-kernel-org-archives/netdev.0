From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1 of 2] IPv6: only update the lifetime of the relevant
 temporary address
Date: Wed, 02 Apr 2008 00:02:08 -0700 (PDT)
Message-ID: <20080402.000208.151037088.davem@davemloft.net>
References: <patchbomb.1207091339@pirzuine>
	<0c33481968e0b6b8efd7.1207091340@pirzuine>
	<20080402.084836.12035236.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot@ens-lyon.org, netdev@vger.kernel.org,
	pekkas@netcore.fi
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47903
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755902AbYDBHCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 03:02:08 -0400
In-Reply-To: <20080402.084836.12035236.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 02 Apr 2008 08:48:36 +0900 (JST)

> In article <0c33481968e0b6b8efd7.1207091340@pirzuine> (at Wed, 02 Apr 2008 01:09:00 +0200), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:
> 
> > IPv6: only update the lifetime of the relevant temporary address
> > 
> > When receiving a prefix information from a routeur, only update the lifetimes
> > of the temporary address associated with that prefix.
> > Otherwise if one deprecated prefix is advertized, all your temporary addresses
> > will become deprecated.
> > 
> > Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
