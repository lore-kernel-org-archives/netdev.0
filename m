From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9][v2] mISDN: comment out unused symbols
Date: Fri, 12 Dec 2008 21:18:41 -0800 (PST)
Message-ID: <20081212.211841.94747482.davem@davemloft.net>
References: <49419a3b.0aec660a.2b49.7900@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751363AbYLMFSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:18:40 -0500
In-Reply-To: <49419a3b.0aec660a.2b49.7900@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 11 Dec 2008 22:36:00 +0100

> Fix this sparse warnings:
> 
>   drivers/isdn/hardware/mISDN/hfcmulti.c:794: warning: 'vpm_check' defined but not used
>   drivers/isdn/mISDN/dsp_cmx.c:1546: warning: 'dsp_start_jiffies' defined but not used
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> Acked-by: Karsten Keil <kkeil@suse.de>

Applied.
