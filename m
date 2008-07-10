From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/13]: niu: Add TX multiqueue support.
Date: Thu, 10 Jul 2008 13:52:49 -0700 (PDT)
Message-ID: <20080710.135249.181231909.davem@davemloft.net>
References: <20080710.035729.69923246.davem@davemloft.net>
	<20080710171445.GA5146@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34838
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753514AbYGJUwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 16:52:49 -0400
In-Reply-To: <20080710171445.GA5146@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 10 Jul 2008 21:14:45 +0400

> On Thu, Jul 10, 2008 at 03:57:29AM -0700, David Miller (davem@davemloft.net) wrote:
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > ---
> >  drivers/net/niu.c |   45 +++++++++++++++++++++++++--------------------
> >  1 files changed, 25 insertions(+), 20 deletions(-)
> 
> Out of curiosity, are there some nice graphs of the new multiqueue
> transfer performance or anything like that?

As I've said, I've only done very basic functional testing.  No perf
tests yet.

And, I don't do graphs. :) Others can feel free to do so, but my time
is currently best invested in the code and making sure it's ready in
time for 2.6.27
