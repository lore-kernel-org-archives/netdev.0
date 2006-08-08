From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: airo: inconsistent {hardirq-on-W} -> {in-hardirq-W} usage.
Date: Tue, 8 Aug 2006 09:30:40 -0400
Message-ID: <20060808133035.GA20706@tuxdriver.com>
References: <20060808094410.GA29313@ee.oulu.fi> <E1GAPZF-0003w4-00@gondolin.me.apana.org.au> <20060808113851.GA17861@ee.oulu.fi> <20060808125222.GA15855@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Pietikainen <pp@ee.oulu.fi>, netdev@vger.kernel.org,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:62477 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S964862AbWHHNbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 09:31:48 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060808125222.GA15855@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 10:52:22PM +1000, Herbert Xu wrote:
> On Tue, Aug 08, 2006 at 02:38:51PM +0300, Pekka Pietikainen wrote:

> > Could be http://marc.theaimsgroup.com/?l=linux-netdev&m=115461336523555&w=2
> > which isn't upstream yet, right?
> 
> That's a separate bug fix which should produce an entirely different
> warning.  Although I concede that this patch would make your original
> warning look slightly different :)
> 
> John, could you please push this to Jeff? Thanks.

Already did so, on Friday.

John
-- 
John W. Linville
linville@tuxdriver.com
