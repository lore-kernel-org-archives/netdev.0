From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Established connections hash function
Date: Fri, 23 Mar 2007 11:46:52 -0700 (PDT)
Message-ID: <20070323.114652.39155950.davem@davemloft.net>
References: <4602FD18.7060902@cosmosbay.com>
	<20070323.001126.40983698.davem@davemloft.net>
	<46038908.6050501@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikb@webmaster.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753314AbXCWSqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 14:46:53 -0400
In-Reply-To: <46038908.6050501@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 23 Mar 2007 09:00:08 +0100

> I dont consider this new hash as bug fix at all, ie your patch might enter 
> 2.6.22 normal dev cycle.

Ok, I checked the patch into net-2.6.22
