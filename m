From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface
Date: Thu, 15 May 2008 10:29:13 +0000
Message-ID: <20080515102913.GA6753@ff.dom.local>
References: <20080515091216.GA6550@ff.dom.local> <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kingsley Foreman <kingsley@internode.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758285AbYEOKZ7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2008 at 07:36:54PM +0930, Kingsley Foreman wrote:
...
> i just rolled back the kernel to 2.6.24 and im seeing the same thing,
>
> I was using 2.6.22 before and didn't see the problem, txqueuelen on the  
> bond0 interface is 0 (the default)

So, could you try if the size matters here...?

Jarek P.
