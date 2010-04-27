From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: Wait longer for control packets on
 initialization
Date: Tue, 27 Apr 2010 10:18:55 -0700 (PDT)
Message-ID: <20100427.101855.45893959.davem@davemloft.net>
References: <201004261238.27919.adetsch@br.ibm.com>
	<4BD648FC.80602@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adetsch@br.ibm.com, netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755624Ab0D0RSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:18:50 -0400
In-Reply-To: <4BD648FC.80602@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 26 Apr 2010 19:16:28 -0700

> Andre Detsch wrote:
>> In some Power7 platforms, when using VIOS (Virtual I/O Server), we
>> need to wait longer for control packets to finish transfer during
>> initialization.
>> Without this change, initialization may fail prematurely.
>>
>> Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
>> Signed-off-by: Andre Detsch <adetsch@br.ibm.com>
>>   
> 
> Acked-by: Divy Le Ray <divy@chelsio.com>

Applied.
