From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] [IPV4] SNMP: Display new statistics at
 /proc/net/snmp
Date: Mon, 14 May 2007 03:07:42 -0700 (PDT)
Message-ID: <20070514.030742.18302818.davem@davemloft.net>
References: <20070507202905.e101d8cc.mitch@linux.vnet.ibm.com>
	<20070512011004.e2e3fc7b.mitch@linux.vnet.ibm.com>
	<20070512.011949.88797969.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: mitch@linux.vnet.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37892
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755911AbXENKHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 06:07:36 -0400
In-Reply-To: <20070512.011949.88797969.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sat, 12 May 2007 01:19:49 +0900 (JST)

> In article <20070512011004.e2e3fc7b.mitch@linux.vnet.ibm.com> (at Sat, 12 May 2007 01:10:04 +0900), Mitsuru Chinen <mitch@linux.vnet.ibm.com> says:
> 
> > [IPV4] SNMP: Display new statistics at /proc/net/netstat
> > 
> > This displays the statistics specified in the updated IP-MIB RFC
> > (RFC4293) in /proc/net/netstat. The reason why these are not displayed
> > in /proc/net/snmp is that some existing utilities are developed under
> > the assumption which ipstat items in /proc/net/snmp is unchanged.
> > 
> > Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied, thanks everyone.
