From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPv6] Exclude truncated packets from InHdrErrors
 statistics
Date: Thu, 05 Apr 2007 02:21:52 +0900 (JST)
Message-ID: <20070405.022152.102590102.yoshfuji@linux-ipv6.org>
References: <20070403155551.a84db4f0.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: mitch@linux.vnet.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40314 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbXDDRVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 13:21:06 -0400
In-Reply-To: <20070403155551.a84db4f0.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070403155551.a84db4f0.mitch@linux.vnet.ibm.com> (at Tue, 3 Apr 2007 15:55:51 +0900), Mitsuru Chinen <mitch@linux.vnet.ibm.com> says:

> Incoming trancated packets are counted as not only InTruncatedPkts but
> also InHdrErrors. They should be counted as InTruncatedPkts only.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
