From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for May 16 (net/ipv4/ping)
Date: Mon, 16 May 2011 12:35:34 -0700
Message-ID: <20110516123534.5d3a51b9.randy.dunlap@oracle.com>
References: <20110516151019.be338f1c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110516151019.be338f1c.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 May 2011 15:10:19 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20110513:


when CONFIG_PROC_SYSCTL is not enabled:

ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_group_range_net'

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
