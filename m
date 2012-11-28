From: David Miller <davem@davemloft.net>
Subject: Re: [patch] atm: forever loop loading ambassador firmware
Date: Wed, 28 Nov 2012 11:38:54 -0500 (EST)
Message-ID: <20121128.113854.810409435622014489.davem@davemloft.net>
References: <20121127172935.GB1059@elgon.mountain>
	<20121128104044.785f1041@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, dwmw2@infradead.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930Ab2K1Qi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:38:57 -0500
In-Reply-To: <20121128104044.785f1041@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Wed, 28 Nov 2012 10:40:44 -0500

> On Tue, 27 Nov 2012 20:29:35 +0300
> Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
>> There was a forever loop introduced here when we converted this to
>> request_firmware() back in 2008.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> This certainly does seem to be the case.
> 
> Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied, thanks everyone.
