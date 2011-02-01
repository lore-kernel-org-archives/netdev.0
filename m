From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for February 1 (ip_vs)
Date: Tue, 1 Feb 2011 09:16:20 -0800
Message-ID: <20110201091620.64536300.randy.dunlap@oracle.com>
References: <20110201153403.b3a251a3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110201153403.b3a251a3.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Feb 2011 15:34:03 +1100 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20110131:


When CONFIG_IP_VS_PROTO_TCP is not set:

net/netfilter/ipvs/ip_vs_proto_sctp.c:1104: error: 'struct netns_ipvs' has no member named 'tcp_app_lock'
net/netfilter/ipvs/ip_vs_proto_sctp.c:1104: error: 'struct netns_ipvs' has no member named 'tcp_app_lock'


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
