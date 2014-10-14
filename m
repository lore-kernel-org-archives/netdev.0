From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/3] bug fixes for davinci_cpdma and cpsw drivers
Date: Tue, 14 Oct 2014 15:35:52 -0400 (EDT)
Message-ID: <20141014.153552.2272381009850217880.davem@davemloft.net>
References: <1413219067-15328-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348AbaJNTfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 15:35:54 -0400
In-Reply-To: <1413219067-15328-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Mon, 13 Oct 2014 22:21:04 +0530

> Mugunthan V N (3):
>   drivers: net: davinci_cpdma: remove kfree on objects allocated with
>     devm_* apis
>   drivers: net: davinci_cpdma: remove spinlock as SOFTIRQ-unsafe lock
>     order detected
>   drivers: net: cpsw: remove child devices while driver detach

Series applied, thanks.
