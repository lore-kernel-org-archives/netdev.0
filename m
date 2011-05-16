From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for May 16 (net/ipv4/ping)
Date: Mon, 16 May 2011 15:38:44 -0400 (EDT)
Message-ID: <20110516.153844.1072050131335197211.davem@davemloft.net>
References: <20110516151019.be338f1c.sfr@canb.auug.org.au>
	<20110516123534.5d3a51b9.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	segoon@openwall.com
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110516123534.5d3a51b9.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 16 May 2011 12:35:34 -0700

> On Mon, 16 May 2011 15:10:19 +1000 Stephen Rothwell wrote:
> 
>> Hi all,
>> 
>> Changes since 20110513:
> 
> 
> when CONFIG_PROC_SYSCTL is not enabled:
> 
> ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_group_range_net'

Vasiliy, please fix this.
