From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Sun, 12 Oct 2008 22:16:38 -0400
Message-ID: <20081013021638.GA11825@infradead.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org> <20080923104026.GA12535@infradead.org> <20080923043005.358e19e7.akpm@linux-foundation.org> <20081012110510.GA19600@infradead.org> <20081012191113.4aa0d6ef.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, kkeil@suse.de,
	netdev@vger.kernel.org, andi@firstfloor.org, ak@linux.intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:43008 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbYJMCQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 22:16:59 -0400
Content-Disposition: inline
In-Reply-To: <20081012191113.4aa0d6ef.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 12, 2008 at 07:11:13PM -0700, Andrew Morton wrote:
> > On Sun, 12 Oct 2008 07:05:10 -0400 Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > The bogus version which removes ->llseek just got into Linus' tree..
> 
> Well I still have this queued:

Yeah, that'll fix it.

