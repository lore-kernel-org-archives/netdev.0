From: David Miller <davem@davemloft.net>
Subject: Re: NCR, was [PATCH] make _minimum_ TCP retransmission timeout
 configurable
Date: Wed, 29 Aug 2007 15:59:11 -0700 (PDT)
Message-ID: <20070829.155911.08334782.davem@davemloft.net>
References: <20070829.152812.74548456.davem@davemloft.net>
	<20070829155106.43cf69eb@freepuppy.rosehill.hemminger.net>
	<46D5FA04.1060600@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, ian.mcdonald@jandi.co.nz,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58378
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758958AbXH2W7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 18:59:12 -0400
In-Reply-To: <46D5FA04.1060600@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Wed, 29 Aug 2007 18:58:12 -0400

> I don't believe this was the case.  NCR is substantially different, and 
> came out of work at Texas A&M.  The original (only) implementation was 
> in Linux IIRC.  Its goal was to do better.  Their papers say it does. 
> It might be worth looking at.
> 
> In my own experience with reordering, Alexey's code had some 
> hard-to-track-down bugs (look at all the work Ilpo's been doing), and 
> the relative simplicity of NCR may be one of the reasons it does well in 
> tests.

Interesting, thanks for the info John.
