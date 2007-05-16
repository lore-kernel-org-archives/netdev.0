From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 16 May 2007 16:58:32 +0200
Message-ID: <m3r6pg95nr.fsf@maximus.localdomain>
References: <464034CF.20700@wpkg.org> <20070516071300.GB14222@infradead.org>
	<20070516094100.GB16262@xi.wantstofly.org>
	<464AE10E.7090606@whitby.id.au>
	<20070516105626.GC16262@xi.wantstofly.org>
	<464AEC76.7090000@whitby.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Christoph Hellwig <hch@infradead.org>,
	Tomasz Chmielewski <mangoo@wpkg.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>
To: Rod Whitby <rod@whitby.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36616 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222AbXEPO6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 10:58:33 -0400
In-Reply-To: <464AEC76.7090000@whitby.id.au> (Rod Whitby's message of "Wed, 16 May 2007 21:05:18 +0930")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rod Whitby <rod@whitby.id.au> writes:

> Please let's just stop arguing about it.  If a patch appears before it
> gets merged, then great.  If it doesn't then it will appear at a later date.

Sure. The "swapping" patch is trivial and I can add it if needed
at some point but I hope we can do that "data coherency mode" right.

Personally I'd be pleased if I could run the board LE instead
of BE, with no performance penalty.
-- 
Krzysztof Halasa
