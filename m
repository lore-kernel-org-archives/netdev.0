From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 6/6] [IPV4] SNMP: Display new statistics at
 /proc/net/snmp
Date: Sat, 12 May 2007 01:19:49 +0900 (JST)
Message-ID: <20070512.011949.88797969.yoshfuji@linux-ipv6.org>
References: <20070503.031546.83595703.davem@davemloft.net>
	<20070507202905.e101d8cc.mitch@linux.vnet.ibm.com>
	<20070512011004.e2e3fc7b.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: mitch@linux.vnet.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37585 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762352AbXEKQTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 12:19:34 -0400
In-Reply-To: <20070512011004.e2e3fc7b.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070512011004.e2e3fc7b.mitch@linux.vnet.ibm.com> (at Sat, 12 May 2007 01:10:04 +0900), Mitsuru Chinen <mitch@linux.vnet.ibm.com> says:

> [IPV4] SNMP: Display new statistics at /proc/net/netstat
> 
> This displays the statistics specified in the updated IP-MIB RFC
> (RFC4293) in /proc/net/netstat. The reason why these are not displayed
> in /proc/net/snmp is that some existing utilities are developed under
> the assumption which ipstat items in /proc/net/snmp is unchanged.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
