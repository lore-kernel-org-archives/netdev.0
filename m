From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch RFC 3/3] b44: convert to ssb module
Date: Tue, 15 Aug 2006 16:49:58 +0200
Message-ID: <200608151649.58875.mb@bu3sch.de>
References: <200608150014.19661.mb@bu3sch.de> <200608151614.16640.mb@bu3sch.de> <20060815143331.GC28544@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:962
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030325AbWHOOvO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 10:51:14 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060815143331.GC28544@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 August 2006 16:33, John W. Linville wrote:
> On Tue, Aug 15, 2006 at 04:14:16PM +0200, Michael Buesch wrote:
> 
> > You can take a look at the new DMA engine code of bcm43xx.
> > It's the same engine.
> > 
> > BTW: John, I see that the new DMA engine code is not applied
> > to wireless-dev (64-bit DMA and >1G support). But I think I
> > already sent the patch. Where did it get lost? Was it my fault?
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=115056542006772&w=2

Hm, I _think_ that was the right one.
But I will dig out the right one and resend to make sure things don't
randomly break.

> Is this the patch?  I think this one is a victim of the "RFT" subject.
> Oh, and the patch seemed to not be totally working based on this post:
> 
> 	http://marc.theaimsgroup.com/?l=linux-netdev&m=115075858220477&w=2

I think this oops comes from buggy (or too new) firmware.
I think we can ignore it for now.

-- 
Greetings Michael.
