From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH 2/24] make atomic_read() behave consistently on arm
Date: Thu, 9 Aug 2007 17:06:49 +0100
Message-ID: <20070809160649.GA16405@flint.arm.linux.org.uk>
References: <20070809133028.GA13241@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S940767AbXHIQJw@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070809133028.GA13241@shell.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 09:30:28AM -0400, Chris Snook wrote:
> From: Chris Snook <csnook@redhat.com>
> 
> Purify volatile use for atomic_t on arm.
> 
> Signed-off-by: Chris Snook <csnook@redhat.com>

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
