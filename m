From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv6] Exclude truncated packets from InHdrErrors
 statistics
Date: Wed, 04 Apr 2007 23:55:09 -0700 (PDT)
Message-ID: <20070404.235509.96682906.davem@davemloft.net>
References: <20070403155551.a84db4f0.mitch@linux.vnet.ibm.com>
	<20070405.022152.102590102.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: mitch@linux.vnet.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1945968AbXDEGzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 02:55:09 -0400
In-Reply-To: <20070405.022152.102590102.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 05 Apr 2007 02:21:52 +0900 (JST)

> In article <20070403155551.a84db4f0.mitch@linux.vnet.ibm.com> (at Tue, 3 Apr 2007 15:55:51 +0900), Mitsuru Chinen <mitch@linux.vnet.ibm.com> says:
> 
> > Incoming trancated packets are counted as not only InTruncatedPkts but
> > also InHdrErrors. They should be counted as InTruncatedPkts only.
> > 
> > Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks everyone.
