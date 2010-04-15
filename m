From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] net: replace ipfragok with
 skb->local_df
Date: Thu, 15 Apr 2010 15:33:15 -0700 (PDT)
Message-ID: <20100415.153315.262788071.davem@davemloft.net>
References: <4BC70EF1.6080400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, yinghai.lu@oracle.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	" <netdev@vger.kernel.org>, dccp@vger.kernel.org, linux-sctp@vger.kernel.org"@tang.cn.fujitsu.com
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47705
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756523Ab0DOWdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 18:33:11 -0400
In-Reply-To: <4BC70EF1.6080400@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Your netdev entry on the CC: list was literally:

	" <netdev@vger.kernel.org>,

which caused your patch to not make it netdev and therefore
it also didn't make it into patchwork.

Please resubmit your patches (both of them) with the CC:
list fixed up.

Thank you.
