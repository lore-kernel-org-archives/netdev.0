From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 13/24] make atomic_read() behave consistently on mips
Date: Thu, 9 Aug 2007 21:09:27 +0100
Message-ID: <20070809200927.GA17855@linux-mips.org>
References: <20070809140004.GA17112@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:43749 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbXHJLFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 07:05:11 -0400
Received: from localhost.localdomain ([127.0.0.1]:3999 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20026882AbXHJLFK (ORCPT <rfc822;netdev@vger.kernel.org>
	+ 2 others); Fri, 10 Aug 2007 12:05:10 +0100
Content-Disposition: inline
In-Reply-To: <20070809140004.GA17112@shell.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 10:00:04AM -0400, Chris Snook wrote:

> Purify volatile use for atomic[64]_t on mips.
> 
> Signed-off-by: Chris Snook <csnook@redhat.com>

Acked-by: Ralf Baechle <ralf@linux-mips.org>
