From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_input() and ->seq oddities
Date: Tue, 12 Feb 2008 22:54:43 -0800 (PST)
Message-ID: <20080212.225443.86986730.davem@davemloft.net>
References: <20080203030516.GA5685@gondor.apana.org.au>
	<20080203110444.GR27894@ZenIV.linux.org.uk>
	<20080203220027.GA11641@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56745
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751759AbYBMGyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:54:11 -0500
In-Reply-To: <20080203220027.GA11641@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 4 Feb 2008 09:00:27 +1100

> On Sun, Feb 03, 2008 at 11:04:44AM +0000, Al Viro wrote:
> > IMO that at least deserves a comment near xfrm_input()...
> 
> Sure.  There is already a comment about encap_type < 0 in there, but
> I think you'll probably be able to explain it much better than I can
> looking in from the outside so if you have a patch... :)

Agreed on all counts ;-)
