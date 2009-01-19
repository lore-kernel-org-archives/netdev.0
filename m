From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Mon, 19 Jan 2009 15:21:14 -0800 (PST)
Message-ID: <20090119.152114.259246950.davem@davemloft.net>
References: <20090118.214729.257523668.davem@davemloft.net>
	<20090119111656.GB2575@gondor.apana.org.au>
	<9929d2390901191434k3d5fa598kad5a797ca4928c70@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48740
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752982AbZASXVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 18:21:13 -0500
In-Reply-To: <9929d2390901191434k3d5fa598kad5a797ca4928c70@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jan 2009 14:34:22 -0800

> On Mon, Jan 19, 2009 at 3:16 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > On Sun, Jan 18, 2009 at 09:47:29PM -0800, David Miller wrote:
> >> From: Herbert Xu <herbert@gondor.apana.org.au>
> >> Date: Tue, 13 Jan 2009 20:28:28 +1100
> >>
> >> > igb: Replace LRO with GRO
> >>  ...
> >> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >>
> >> Have the crashes reported by Intel been sorted out yet?
> >> If so, I'll queue this up for 2.6.30
> >>
> >> Otherwise please resubmit once the problem is resolved.
> >
> > I believe it should be cured.  But it wouldn't hurt to wait for
> > them to reconfirm.
> >
> > Thanks,
> > --
> > Visit Openswan at http://www.openswan.org/
> > Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> > Home Page: http://gondor.apana.org.au/~herbert/
> > PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> > --
> >
> 
> Last word I have from test is that igb loads fine now, and no kernel
> panics have been reported.
> Go ahead and queue it up for 2.6.30.

Done, thanks!
