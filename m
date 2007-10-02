From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 11:40:32 -0700
Message-ID: <20071002184032.GB29944@bitmover.com>
References: <20070929142517.EC6AB5FB21@work.bitmover.com> <alpine.LFD.0.999.0709290914410.3579@woody.linux-foundation.org> <20070929172639.GB7037@bitmover.com> <alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org> <20071002005917.GB5480@bitmover.com> <alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org> <20071002022059.GE7037@bitmover.com> <47027C63.803@hp.com> <20071002172002.GO17418@bitmover.com> <4702878B.4040102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry McVoy <lm@bitmover.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	davem@davemloft.net, wscott@bitmover.com, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43665 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753283AbXJBSkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 14:40:33 -0400
Content-Disposition: inline
In-Reply-To: <4702878B.4040102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 11:01:47AM -0700, Rick Jones wrote:
> has anyone already asked whether link-layer flow-control is enabled?

I doubt it, the same test works fine in one direction and poorly in the other.
Wouldn't the flow control squelch either way?
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
