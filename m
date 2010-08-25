From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2x: small fix in stats handling
Date: Wed, 25 Aug 2010 16:29:35 -0700 (PDT)
Message-ID: <20100825.162935.179946627.davem@davemloft.net>
References: <1282628648.2378.1492.camel@edumazet-laptop>
	<1282708549.18068.0.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, dmitry@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60452
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751181Ab0HYX3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:29:20 -0400
In-Reply-To: <1282708549.18068.0.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 25 Aug 2010 06:55:49 +0300

> On Mon, 2010-08-23 at 22:44 -0700, Eric Dumazet wrote:
>> Use a private variable to fold rx_dropped value, instead of shared
>> destination buffer, as it might break SNMP applications.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Eilon Greenstein <eilong@broadcom.com>
>> CC: Dmitry Kravkov <dmitry@broadcom.com>
> 
> Thanks Eric!
> 
> Acked-By: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
