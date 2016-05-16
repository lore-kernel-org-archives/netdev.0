From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v2 0/4] net: w5100: collection of small changes
Date: Mon, 16 May 2016 13:56:03 -0400 (EDT)
Message-ID: <20160516.135603.1071124877032992758.davem@davemloft.net>
References: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, msink@permonline.ru
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484AbcEPR4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:56:05 -0400
In-Reply-To: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 14 May 2016 14:55:46 +0900

> This patch series is the collection of relatively small changes for
> w5100 driver which includes a cleanup with no functional change,
> two fixes, and adding a functionality.
> 
> * Changes from v1
> - Remove the watchdong_timeo assignment to set default tx timeout,
>   suggested by David Miller.

Series applied, thanks.
