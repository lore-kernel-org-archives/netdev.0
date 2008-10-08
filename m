From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Wed, 8 Oct 2008 18:04:00 +0200
Message-ID: <20081008160400.GA32211@1wt.eu>
References: <20081008081109.GA25342@1wt.eu> <20081008085034.910551dc.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4669 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752788AbYJHQFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 12:05:13 -0400
Content-Disposition: inline
In-Reply-To: <20081008085034.910551dc.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 08:50:34AM -0700, Randy Dunlap wrote:
> > +	If you want absolute compatibility with any possible application,
> > +	you should set it to 1. If you prefer to enhance security on your
> > +	systems you'd better let it to 0. After four years of usage on
> 
> 	                     set it to 0.
> or did you mean: (?)
> 	                     let it be 0.

I meant "leave it" but I'd prefer "let it be 0".

Thanks Randy,
Willy

