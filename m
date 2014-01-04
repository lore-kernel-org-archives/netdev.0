From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] tg3: Unicast filter support and misc fixes
Date: Fri, 03 Jan 2014 21:00:18 -0500 (EST)
Message-ID: <20140103.210018.1389281300133624707.davem@davemloft.net>
References: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbaADCAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 21:00:20 -0500
In-Reply-To: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@broadcom.com>
Date: Fri, 3 Jan 2014 10:09:10 -0800

> Michael Chan (2):
>   tg3: Refactor __tg3_set_mac_addr()
>   tg3: Add unicast filtering support.
> 
> Nithin Nayak Sujir (3):
>   tg3: Set the MAC clock to the fastest speed during boot code load
>   tg3: Poll cpmu link state on APE + ASF enabled devices
>   tg3: Update version to 3.136

Series applied, thanks.
