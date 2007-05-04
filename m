From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
Date: Fri, 4 May 2007 09:09:13 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705040908480.21436@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>
 <84144f020705040354r5cb74c5fj6cb8698f93ffcb83@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@steeleye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:38133 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1031061AbXEDQJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 12:09:14 -0400
In-Reply-To: <84144f020705040354r5cb74c5fj6cb8698f93ffcb83@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 May 2007, Pekka Enberg wrote:

> On 5/4/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > Expost buffer_size in order to allow fair estimates on the actual space
> > used/needed.

We already have ksize?

