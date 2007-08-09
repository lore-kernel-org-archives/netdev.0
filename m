From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 16/24] make atomic_read() behave consistently on s390
Date: Thu, 09 Aug 2007 16:36:48 +0200
Message-ID: <1186670208.9669.9.camel@localhost>
References: <20070809140655.GA17731@shell.boston.redhat.com>
Reply-To: schwidefsky@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:62993 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S940661AbXHIOdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 10:33:11 -0400
In-Reply-To: <20070809140655.GA17731@shell.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-09 at 10:06 -0400, Chris Snook wrote:
> From: Chris Snook <csnook@redhat.com>
> 
> Make atomic[64]_read() volatile on s390, to ensure memory is actually read
> each time.
> 
> Signed-off-by: Chris Snook <csnook@redhat.com>

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


