From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] cxgb3: Set the rxq
Date: Sat, 24 Oct 2009 07:07:15 -0700 (PDT)
Message-ID: <20091024.070715.241603365.davem@davemloft.net>
References: <20091023111321.4726.29354.sendpatchset@localhost.localdomain>
	<op.u193nu1zduofyu@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38599
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753315AbZJXOGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 10:06:52 -0400
In-Reply-To: <op.u193nu1zduofyu@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Divy Le Ray" <divy@chelsio.com>
Date: Fri, 23 Oct 2009 17:29:44 -0700

> On Fri, 23 Oct 2009 04:13:21 -0700, Krishna Kumar
> <krkumar2@in.ibm.com> wrote:
> 
>> From: Krishna Kumar <krkumar2@in.ibm.com>
>>
>> Set the rxq# for LRO when processing the last fragment of a
>> frame. This helps in fast txq selection for routing workloads.
>>
>> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Acked-by: Divy Le Ray <divy@chelsio.com>

Applied to net-next-2.6, thanks!
