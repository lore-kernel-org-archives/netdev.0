From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/6] netpoll: recursion fixes, queueing, and cleanups
Date: Tue, 22 Mar 2005 18:33:20 -0800
Message-ID: <20050322183320.3ef997ef.davem@davemloft.net>
References: <1.378217222@selenic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jmoyer@redhat.com
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1.378217222@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Feb 2005 23:25:18 -0600
Matt Mackall <mpm@selenic.com> wrote:

> This patch series against -rc4 fixes up some recursion deadlocks in
> netpoll and adds support for fallback to queueing. Various cleanups
> along the way.
> 
> Holds up under load testing via ipt_LOG on a dual Opteron with tg3.

I've applied all 6 patches to my tree.  Sorry for taking so long
Matt.
