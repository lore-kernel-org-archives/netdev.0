From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator: fix locking and timer related bugs [Re: [Bugme-new] [Bug 8668] New: HTB Deadlock]
Date: Thu, 28 Jun 2007 15:27:17 +0200
Message-ID: <20070628132717.GC3284@ff.dom.local>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net> <46827DB1.3060509@trash.net> <46828179.5030404@trash.net> <20070628091339.GC1618@ff.dom.local> <4683A848.5040907@trash.net> <20070628130335.GA3284@ff.dom.local> <4683AFD7.8080605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:60795 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755075AbXF1NTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 09:19:06 -0400
Content-Disposition: inline
In-Reply-To: <4683AFD7.8080605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 28, 2007 at 02:55:51PM +0200, Patrick McHardy wrote:
...
> Its overkill in that case. The concurrent additions and removals
> can't happen.
> 

Then the changelog needs one more change. Plus, maybe - btw,
1 line about this at the beginning of the file?

Jarek P.
