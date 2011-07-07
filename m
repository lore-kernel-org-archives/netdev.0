From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for July 7 (net/af_packet)
Date: Thu, 7 Jul 2011 08:12:02 -0700
Message-ID: <20110707081202.6dddcbce.randy.dunlap@oracle.com>
References: <20110707172544.867b980a1196db005b577c14@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110707172544.867b980a1196db005b577c14@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jul 2011 17:25:44 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> The next linux-next release will (probably) be next-20110718.
> 
> Changes since 20110706:


When CONFIG_INET is not enabled:

af_packet.c:(.text+0x3d130): undefined reference to `ip_defrag'
or
ERROR: "ip_defrag" [net/packet/af_packet.ko] undefined!

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
