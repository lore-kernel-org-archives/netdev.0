From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove NPROTO.
Date: Wed, 12 Mar 2008 04:13:18 -0700 (PDT)
Message-ID: <20080312.041318.193687381.davem@davemloft.net>
References: <200803121224.25228.rusty@rustcorp.com.au>
	<20080311.211441.105701252.davem@davemloft.net>
	<200803121834.26493.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45297
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751300AbYCLLNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 07:13:11 -0400
In-Reply-To: <200803121834.26493.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 12 Mar 2008 18:34:26 +1100

> On Wednesday 12 March 2008 15:14:41 David Miller wrote:
> > Redundant, but exported to userspace for about 15 years.
> >
> > We'd be wise to not remove it.
> 
> Thanks.  Should we #define NPROTO AF_MAX then?

I can't see a reason why not.
