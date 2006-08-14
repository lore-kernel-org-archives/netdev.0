From: Paul Jackson <pj@sgi.com>
Subject: Re: rename *MEMALLOC flags
Date: Sun, 13 Aug 2006 18:00:54 -0700
Message-ID: <20060813180054.65201239.pj@sgi.com>
References: <20060812141415.30842.78695.sendpatchset@lappy>
	<20060812141445.30842.47336.sendpatchset@lappy>
	<44DDE8B6.8000900@garzik.org>
	<1155395201.13508.44.camel@lappy>
	<44DFBEA3.5070305@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, jeff@garzik.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, indan@nul.nu,
	johnpol@2ka.mipt.ru, riel@redhat.com, davem@davemloft.net,
	Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx1-ext.sgi.com ([192.48.179.11]:10660 "EHLO
	omx1.americas.sgi.com") by vger.kernel.org with ESMTP
	id S1751181AbWHNBBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 21:01:31 -0400
To: Daniel Phillips <phillips@google.com>
In-Reply-To: <44DFBEA3.5070305@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel wrote:
> Inventing a new name for an existing thing is very poor taste on grounds of
> grepability alone.

I wouldn't say 'very poor taste' -- just something that should be
done infrequently, with good reason, and with reasonable concensus,
especially from the key maintainers in the affected area.

Good names are good taste, in my book.  But stable naming is good too.

I wonder what Nick thinks of this?  Looks like he added
__GFP_NOMEMALLOC a year ago, following the naming style of PF_MEMALLOC.

I added him to the cc list.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
