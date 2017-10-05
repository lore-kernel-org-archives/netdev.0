From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next v6 0/4] bpf: add two helpers to read perf event
 enabled/running time
Date: Thu, 5 Oct 2017 10:34:37 +0200
Message-ID: <20171005083437.v3yfluazdy5du7pi@hirez.programming.kicks-ass.net>
References: <20171002224218.3181418-1-yhs@fb.com>
 <20171004.160056.801262768847050741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yhs@fb.com, rostedt@goodmis.org, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:35039 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbdJEIet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 04:34:49 -0400
Content-Disposition: inline
In-Reply-To: <20171004.160056.801262768847050741.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 04:00:56PM -0700, David Miller wrote:
> From: Yonghong Song <yhs@fb.com>
> Date: Mon, 2 Oct 2017 15:42:14 -0700
> 
> > [Dave, Peter,
> > 
> >  Previous communcation shows that this patch may potentially have
> >  merge conflict with upcoming tip changes in the next merge window.
> > 
> >  Could you advise how this patch should proceed?
> > 
> >  Thanks!
> > ]
> 
> Indeed, Peter how do you want to handle this?

I think Alexei suggested that we merge the one patch in two branches and
let git sort it out. I _think_ I've done something similar before and it
worked.
