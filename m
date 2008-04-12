From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] forcedeth: new backoff implementation
Date: Fri, 11 Apr 2008 21:50:56 -0700
Message-ID: <20080411215056.6338f4e3.akpm@linux-foundation.org>
References: <47FE7066.5060703@nvidia.com>
	<200804111852.39156.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	nedev <netdev@vger.kernel.org>
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56370 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752267AbYDLEvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 00:51:23 -0400
In-Reply-To: <200804111852.39156.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Apr 2008 18:52:38 +0200 Ingo Oeser <netdev@axxeo.de> wrote:

> Subject: Re: [PATCH] forcedeth: new backoff implementation

Dumb question: is there anything particularly forcedeth-specific in this
new backoff implementation?

If not, and if it might be valuable to other drivers, should it not be
implemented that way?



In an ideal world, I'd have been able to answer my own question by reading
the changelog, but it's a rather poor changelog, sorry.  It doesn't even
tell us why forcedeth needs a new backoff implementation.

