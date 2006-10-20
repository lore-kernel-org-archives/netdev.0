From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 13:25:32 -0700
Message-ID: <20061020132532.65a3e655@dxpl.pdx.osdl.net>
References: <20061020081857.743b5eb7@localhost.localdomain>
	<20061020.122427.55507415.davem@davemloft.net>
	<20061020122527.56292b56@dxpl.pdx.osdl.net>
	<20061020.125226.59656580.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63960 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422820AbWJTUZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 16:25:36 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061020.125226.59656580.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Oct 2006 12:52:26 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 20 Oct 2006 12:25:27 -0700
> 
> > Sorry, but why should we treat out-of-tree vendor code any
> > differently than out-of-tree other code.
> 
> I think what netdump was trying to do, provide a way to
> requeue instead of fully drop the SKB, is quite reasonable.
> Don't you think?


Netdump doesn't even exist in the current Fedora source rpm.
I think Dave dropped it.
