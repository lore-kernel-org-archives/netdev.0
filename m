From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] netpoll: allow spaces in its parameter
Date: Tue, 16 Mar 2010 22:54:31 -0700 (PDT)
Message-ID: <20100316.225431.200776775.davem@davemloft.net>
References: <20100317055707.5013.72217.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100317055707.5013.72217.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 17 Mar 2010 01:53:26 -0400

> 
> It would be nice if we allow spaces in netconsole parameters,
> otherwise we get weird results if there are spaces in it.
> 
> After this patch, we will allow things like:
>  "netconsole= @192.168.0.1/eth0 , 66666@192.168.0.2/".
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: David Miller <davem@davemloft.net>

That kernel command line looks absolutely awful, not
better.

Sorry I'm not applying this.
