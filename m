From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] sky2: missing chip name for Yukon Supreme
Date: Thu, 10 Apr 2008 15:21:49 -0500
Message-ID: <20080410152149.3480e2d0@speedy>
References: <20080410150614.7da71ff8@speedy>
	<20080410201421.GA27486@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:46180 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755966AbYDJUVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 16:21:54 -0400
In-Reply-To: <20080410201421.GA27486@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Apr 2008 16:14:21 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Apr 10, 2008 at 03:06:14PM -0500, Stephen Hemminger wrote:
> > Any usage of sky2 on new Yukon Supreme would cause a NULL dereference.
> > The chip is very new, so the support is still untested; vendor has
> > not sent any eval hardware.
> 
> What about also making the driver not oops in case another variant is added?

Many more changes will be needed for the next new variant. They never do
the same thing.
