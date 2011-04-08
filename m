From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tg3: convert to hw_features
Date: Thu, 07 Apr 2011 20:18:21 -0700 (PDT)
Message-ID: <20110407.201821.189708284.davem@davemloft.net>
References: <20110407133507.13FDA13909@rere.qmqm.pl>
	<20110407202328.GA18645@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36118
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757358Ab1DHDS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 23:18:57 -0400
In-Reply-To: <20110407202328.GA18645@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 7 Apr 2011 13:23:28 -0700

> Nice cleanup.  I visually studied it for a bit and didn't find anything
> wrong.
> 
> Acked-by: Matt Carlson <mcarlson@broadcom.com>
> 
> On Thu, Apr 07, 2011 at 06:35:07AM -0700, Micha?? Miros??aw wrote:
>> Cleanup hint: Some features are calculated in tg3_get_invariants() and
>> the rest in its caller --- tg3_init_one(). This is not changed here.
>> 
>> Signed-off-by: Micha?? Miros??aw <mirq-linux@rere.qmqm.pl>

Applied.
