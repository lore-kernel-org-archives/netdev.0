From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
Date: Tue, 26 Feb 2008 09:56:05 -0800
Message-ID: <20080226095605.62edc0f3.akpm@linux-foundation.org>
References: <20080220144610.548202000@chello.nl>
	<20080223000620.7fee8ff8.akpm@linux-foundation.org>
	<18371.43950.150842.429997@notabene.brown>
	<1204023042.6242.271.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Neil Brown <neilb@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:58341 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757942AbYBZR5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 12:57:15 -0500
In-Reply-To: <1204023042.6242.271.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Feb 2008 11:50:42 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Tue, 2008-02-26 at 17:03 +1100, Neil Brown wrote:
> > On Saturday February 23, akpm@linux-foundation.org wrote:
>  
> > > What is the NFS and net people's take on all of this?
> > 
> > Well I'm only vaguely an NFS person, barely a net person, sporadically
> > an mm person, but I've had a look and it seems to mostly make sense.
> 
> Thanks for taking a look, and giving such elaborate feedback. I'll try
> and address these issues asap, but first let me reply to a few points
> here.

Neil's overview of what-all-this-is and how-it-all-works is really good. 
I'd suggest that you take it over, flesh it out and attach it firmly to the
patchset.  It really helps.

