From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 31 Aug 2004 13:16:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831131618.48e740f4.davem@redhat.com>
References: <412DF807.2040703@eurodev.net>
	<20040826141407.38b56729.davem@redhat.com>
	<412EB40A.6010100@eurodev.net>
	<20040826214710.5e322f1a.davem@redhat.com>
	<412F1269.8090303@eurodev.net>
	<20040827172736.543dbd54.davem@redhat.com>
	<413276D9.9080303@eurodev.net>
	<20040830172029.164fcf9c.davem@redhat.com>
	<4134A961.20808@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <4134A961.20808@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 31 Aug 2004 18:37:53 +0200
Pablo Neira <pablo@eurodev.net> wrote:

> >It's fine, I'm going to make 2 minor fixes:
> >
> >1) Mark netlink_thread() function static.
> >2) Name the thread "knetlinkd" to be consistent with
> >   other kernel thread names.
> >  
> >
> 
> Attached the version which correct these issues.

You misunderstood, I made these fixes for you in my tree :)
