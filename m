From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9][v2] mISDN: use NULL pointer instead of plain
 integer
Date: Fri, 12 Dec 2008 21:13:05 -0800 (PST)
Message-ID: <20081212.211305.162952487.davem@davemloft.net>
References: <49419a20.07a0660a.4c25.ffff8ce9@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37012
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYLMFNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:13:04 -0500
In-Reply-To: <49419a20.07a0660a.4c25.ffff8ce9@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 11 Dec 2008 22:36:00 +0100

> Fix more than 100 (all remaining in mISDN) sparse warnings:
> 
>   drivers/isdn/hardware/mISDN/hfcmulti.c:***:**: warning: Using plain integer as NULL pointer
>   drivers/isdn/mISDN/dsp_tones.c:***:**: warning: Using plain integer as NULL pointer
>   drivers/isdn/mISDN/dsp_pipeline.c:***:**: warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> Acked-by: Karsten Keil <kkeil@suse.de>

Applied.
