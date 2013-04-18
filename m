From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bnx2x: Bug fixes patch series
Date: Thu, 18 Apr 2013 15:04:12 -0400 (EDT)
Message-ID: <20130418.150412.1489636099120010588.davem@davemloft.net>
References: <1366274946-11625-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab3DRTEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 15:04:16 -0400
In-Reply-To: <1366274946-11625-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 18 Apr 2013 11:49:04 +0300

> Hi Dave,
> 
> This patch contain fixes in two areas -
> 
>   1. Preventing UNDI FW from illegally accessing memory when it shouldn't.
> 
>   2. Fix interrupt coalescing initialization and configuration when working
>      with multiple CoS.
> 
> Please consider applying these patches to `net'.

Both applied, thanks.
