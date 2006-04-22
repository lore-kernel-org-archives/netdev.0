From: Andi Kleen <ak@suse.de>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Sat, 22 Apr 2006 02:02:59 +0200
Message-ID: <200604220202.59434.ak@suse.de>
References: <20060421010809.6c3cfc34.akpm@osdl.org> <4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@osdl.org>, netdev@vger.kernel.org,
	"Nuri Jawad" <lkml@jawad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:3274 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1750761AbWDVAER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 20:04:17 -0400
To: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 April 2006 19:15, Jesse Brandeburg wrote:
> On 4/21/06, Andrew Morton <akpm@osdl.org> wrote:
> >
> > We do seem to have had a few reports of ppp regressions around this
> > timeframe.
> 
> me too.  I couldn't use 2.6.16 at home on my pppoe connected router
> because it was so slow.  I didn't have time to debug.  I can probably
> try patches and provide more data too.  Tell me what is needed.

I seem to have some trouble on my PPPoE too. But it's not really unusable,
just dropouts now and then.

-Andi
