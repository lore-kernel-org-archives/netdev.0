From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 08/13] dmatest: convert to dma_request_channel
Date: Tue, 18 Nov 2008 15:19:17 -0700
Message-ID: <1227046757.19300.3.camel@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213458.32354.58258.stgit@dwillia2-linux.ch.intel.com>
	 <20081114221704.fe9ea599.akpm@linux-foundation.org>
	 <1227032661.15042.10.camel@dwillia2-linux.ch.intel.com>
	 <20081118125840.e3c7745d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54007 "EHLO mga02.intel.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752351AbYKRWTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 17:19:19 -0500
In-Reply-To: <20081118125840.e3c7745d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-11-18 at 13:58 -0700, Andrew Morton wrote:
> On Tue, 18 Nov 2008 11:24:21 -0700
> Dan Williams <dan.j.williams@intel.com> wrote:
> 
> > Ok, so I now have:
> > # git shortlog `stg id akpm-review-spell-fixes.patch`^..
> > Dan Williams (6):
> >       dmaengine review: spelling/grammar fixes
> >       dmaengine review: dma_wait_for_async_tx clarification
> >       dmaengine review: fix up kernel doc for dma_list_mutex usage
> >       dmaengine review: propagate alloc_chan_resources error code
> >       dmaengine review: return meaningful error code from initcall
> >       dmaengine review: dmatest stop on dmatest_add_channel failure
> > 
> > May I add your Reviewed-by for these and the original 13.
> 
> Sure.  Ignorantly-stared-at-by: would be more appropriate though.

This is the problem with the Reviewed-by tag, it implies some kind of
reputation injuring side effect when the bug is found rather than a
author-driven "thank-you for taking the time to make some helpful
comments".

--
Dan

