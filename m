From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] qlcnic: Fix Compilation Issue when
 CONFIG_INET was not set
Date: Thu, 03 Jun 2010 20:05:50 -0700 (PDT)
Message-ID: <20100603.200550.39168599.davem@davemloft.net>
References: <alpine.OSX.2.00.1006031034500.48386@macintosh-2.qlogic.org>
	<20100603112006.0827a847.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirban.chakraborty@qlogic.com, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	amit.salecha@qlogic.com
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932161Ab0FDDFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:05:40 -0400
In-Reply-To: <20100603112006.0827a847.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 3 Jun 2010 11:20:06 -0700

> On Thu, 3 Jun 2010 10:50:56 -0700 Anirban Chakraborty wrote:
> 
>> Please apply.
>> 
>> thanks,
>> Anirban
>> 
>> Original code was placed incorrectly inside a block of code marked
>> with CONFIG_INET directive. Fix by moving it outside.
>> 
>> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Tested-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks everyone.
