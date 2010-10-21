From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] cxgb3: function namespace cleanup
Date: Thu, 21 Oct 2010 07:19:31 -0700 (PDT)
Message-ID: <20101021.071931.226776481.davem@davemloft.net>
References: <20101015224309.179898823@vyatta.com>
	<20101015224523.536739529@vyatta.com>
	<4CBCF10C.4010900@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, leedom@chelsio.com, dm@chelsio.com,
	netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49525
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932274Ab0JUOTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 10:19:08 -0400
In-Reply-To: <4CBCF10C.4010900@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 18 Oct 2010 18:14:52 -0700

>  On 10/15/2010 03:43 PM, Stephen Hemminger wrote:
>> Make local functions static. Remove functions that are
>> defined and never used. Compile tested only.
>>
>> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
> 
> Acked-by: Divy Le Ray <divy@chelsio.com>

Applied.
