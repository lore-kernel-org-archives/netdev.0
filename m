From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH ipv4 multicast] Fix IPv4 multicast over network namespaces
Date: Tue, 27 Mar 2012 20:49:54 -0400
Message-ID: <20120328004954.GC2367@kvack.org>
References: <20120327161228.GA2367@kvack.org> <20120327.173541.1721499825104013533.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:56813 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757516Ab2C1Atz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 20:49:55 -0400
Content-Disposition: inline
In-Reply-To: <20120327.173541.1721499825104013533.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 27, 2012 at 05:35:41PM -0400, David Miller wrote:
> No signoff.

My apologies.  Doing this manually clearly isn't working, so I've switched 
to a script to try to catch this.

> No proper subsystem prefix in Subject line (should be "ipv4: " here)

I'm trying to get this right, and it looks like I botched this again, for 
that I am truely sorry.

		-ben

> And third you've been warned about this repeatedly in your previous
> patch postings.
> 
> Therefore I'm not applying this.

-- 
"Thought is the essence of where you are now."
