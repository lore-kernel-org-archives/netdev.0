From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] bnx2x: unlock before returning an error
Date: Wed, 25 Jan 2012 16:59:03 -0500 (EST)
Message-ID: <20120125.165903.1769846144915753254.davem@davemloft.net>
References: <20120125075931.GA20199@elgon.mountain>
	<1327479294.11041.3.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, eilong@broadcom.com,
	yuvalmin@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842Ab2AYV7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 16:59:09 -0500
In-Reply-To: <1327479294.11041.3.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 25 Jan 2012 10:14:54 +0200

> On Wed, 2012-01-25 at 10:59 +0300, Dan Carpenter wrote:
>> We introduced a new return here but forgot to drop the lock.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
 ...
> Acked-by: Dmitry Kravkov <dmitry@broadcom.com>

Applied, thanks.
