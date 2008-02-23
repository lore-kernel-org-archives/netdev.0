From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/28] mm: __GFP_MEMALLOC
Date: Sat, 23 Feb 2008 00:06:01 -0800
Message-ID: <20080223000601.d35912d4.akpm@linux-foundation.org>
References: <20080220144610.548202000@chello.nl>
	<20080220150306.424308000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:49347 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933038AbYBWIIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 03:08:53 -0500
In-Reply-To: <20080220150306.424308000@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008 15:46:19 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> __GFP_MEMALLOC will allow the allocation to disregard the watermarks, 
> much like PF_MEMALLOC.
> 

'twould be nice if the changelog had some explanation of the reason
for this change.
