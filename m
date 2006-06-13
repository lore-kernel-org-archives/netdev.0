From: David Miller <davem@davemloft.net>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Tue, 13 Jun 2006 00:31:45 -0700 (PDT)
Message-ID: <20060613.003145.71163368.davem@davemloft.net>
References: <200606130654.14477.ak@suse.de>
	<20060612.220346.71553967.davem@davemloft.net>
	<20060613071819.GB16358@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, jeremy@goop.org, lkml@rtr.ca, mpm@selenic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30910
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932948AbWFMHbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 03:31:34 -0400
To: hch@infradead.org
In-Reply-To: <20060613071819.GB16358@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 13 Jun 2006 08:18:19 +0100

> That's actually not portable to certain arm platforms, but that's
> a different story.

Yes, cache issues :-/
