From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 05/33] mm: kmem_estimate_pages()
Date: Wed, 31 Oct 2007 14:43:17 +1100
Message-ID: <200710311443.18143.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl> <20071030160911.281698000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.mail.mud.yahoo.com ([209.191.85.214]:25774 "HELO
	smtp104.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752719AbXJaEt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 00:49:57 -0400
In-Reply-To: <20071030160911.281698000@chello.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> Provide a method to get the upper bound on the pages needed to allocate
> a given number of objects from a given kmem_cache.
>

Fair enough, but just to make it a bit easier, can you provide a
little reason of why in this patch (or reference the patch number
where you use it, or put it together with the patch where you use
it, etc.).

Thanks,
