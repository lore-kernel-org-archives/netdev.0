From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2 of 2] IPv6: do not create temporary adresses with too
 short preferred lifetime
Date: Wed, 02 Apr 2008 00:02:15 -0700 (PDT)
Message-ID: <20080402.000215.75404525.davem@davemloft.net>
References: <patchbomb.1207091339@pirzuine>
	<00affc24c178e6da3a3b.1207091341@pirzuine>
	<20080402.085011.124380410.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot@ens-lyon.org, netdev@vger.kernel.org,
	pekkas@netcore.fi
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47909
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755499AbYDBHCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 03:02:15 -0400
In-Reply-To: <20080402.085011.124380410.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 02 Apr 2008 08:50:11 +0900 (JST)

> In article <00affc24c178e6da3a3b.1207091341@pirzuine> (at Wed, 02 Apr 2008 01:09:01 +0200), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:
> 
> > IPv6: do not create temporary adresses with too short preferred lifetime
> > 
> > >From RFC341:
> > A temporary address is created only if this calculated Preferred
> > Lifetime is greater than REGEN_ADVANCE time units.  In particular,
> > an implementation must not create a temporary address with a zero
> > Preferred Lifetime.
> > 
> > Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
