From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Mon, 13 Oct 2008 04:56:58 -0700
Message-ID: <20081013045658.e6645ebb.akpm@linux-foundation.org>
References: <20080923043005.358e19e7.akpm@linux-foundation.org>
	<20081012110510.GA19600@infradead.org>
	<20081012191113.4aa0d6ef.akpm@linux-foundation.org>
	<20081012.210031.95834473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, kkeil@suse.de, netdev@vger.kernel.org,
	andi@firstfloor.org, ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37008 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756376AbYJML4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 07:56:54 -0400
In-Reply-To: <20081012.210031.95834473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sun, 12 Oct 2008 21:00:31 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Sun, 12 Oct 2008 19:11:13 -0700
> 
> > > On Sun, 12 Oct 2008 07:05:10 -0400 Christoph Hellwig <hch@infradead.org> wrote:
> > > 
> > > The bogus version which removes ->llseek just got into Linus' tree..
> > 
> > Well I still have this queued:
> > 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Cc: Andi Kleen <andi@firstfloor.org>
> > Cc: Karsten Keil <kkeil@suse.de>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Andrew, want me to such this into my net-2.6 tree?

yes please.  I'll send it over with a slight changelog.
