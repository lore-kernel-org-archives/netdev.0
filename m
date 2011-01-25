From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: fix return value of couple of
 store functions
Date: Tue, 25 Jan 2011 13:13:42 -0800 (PST)
Message-ID: <20110125.131342.183052964.davem@davemloft.net>
References: <29198.1295983370@death>
	<20110125210324.GD2932@psychotron.redhat.com>
	<304.1295989626@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753167Ab1AYVNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 16:13:07 -0500
In-Reply-To: <304.1295989626@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 25 Jan 2011 13:07:06 -0800

> Jiri Pirko <jpirko@redhat.com> wrote:
> 
>>count is incorrectly returned even in case of fail. Return ret instead.
>>
>>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks guys.
