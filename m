From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for March 27 (netfilter build error)
Date: Fri, 27 Mar 2009 16:01:07 -0700 (PDT)
Message-ID: <20090327.160107.184169637.davem@davemloft.net>
References: <20090327231924.4e4168c5.sfr@canb.auug.org.au>
	<49CD0368.2010805@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <49CD0368.2010805@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 27 Mar 2009 09:48:40 -0700

> Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20090326:
> 
> 
> with CONFIG_IPV6=n:
> 
> ERROR: "__ipv6_addr_type" [net/netfilter/xt_cluster.ko] undefined!
> 
> config attached.

Patrick and netfilter folks, please have a look, thanks!
