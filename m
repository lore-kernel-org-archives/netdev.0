From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for March 22 (net-sysfs.c)
Date: Mon, 22 Mar 2010 10:22:06 -0700 (PDT)
Message-ID: <20100322.102206.148561893.davem@davemloft.net>
References: <20100322171937.d753bdba.sfr@canb.auug.org.au>
	<4BA78D3D.9090007@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	therbert@google.com
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BA78D3D.9090007@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 22 Mar 2010 08:31:09 -0700

> When CONFIG_SYSFS is not enabled:
> 
> net/core/net-sysfs.c:742: error: implicit declaration of function 'rx_queue_remove_kobjects'
> net/core/net-sysfs.c:783: error: implicit declaration of function 'rx_queue_register_kobjects'
> 

Tom, please fix this.
