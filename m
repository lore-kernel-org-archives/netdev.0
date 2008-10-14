From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 02/14] pkt_sched: Replace all explitic ->dequeue()
	calls with qdisc_dequeue().
Date: Tue, 14 Oct 2008 10:35:30 +0000
Message-ID: <20081014103530.GA11733@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com> <20081014095324.GC10804@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:55442 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754514AbYJNKfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 06:35:36 -0400
Received: by ey-out-2122.google.com with SMTP id 6so750986eyi.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 03:35:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081014095324.GC10804@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 09:53:24AM +0000, Jarek Poplawski wrote:
> -------- Original Message --------
> Subject: [PATCH 4/9]: pkt_sched: Replace all explitic ->dequeue() calls with qdisc_dequeue().
> Date: Mon, 18 Aug 2008 01:36:58 -0700 (PDT)
> From: David Miller <davem@davemloft.net>
> 
> ----------->
> From: David Miller <davem@davemloft.net>
> pkt_sched: Replace all explitic ->dequeue() calls with qdisc_dequeue().

Hmm... these "explitic" typos could be fixed while merging
[PATCH 02/14] and [PATCH 03/14], I guess.

Jarek P.
