From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/13] bnx2x: Control number of vfs dynamically
Date: Tue, 12 Mar 2013 05:28:11 -0400 (EDT)
Message-ID: <20130312.052811.2289109881056913990.davem@davemloft.net>
References: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
	<1363015073-25743-7-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239Ab3CLJ2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 05:28:00 -0400
In-Reply-To: <1363015073-25743-7-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 11 Mar 2013 17:17:46 +0200

> From: Ariel Elior <ariele@broadcom.com>
> 
> 1. Support sysfs interface for getting the maximal number of virtual functions
>    of a given physical function.
> 2. Support sysfs interface for getting and setting the current number of
>    virtual functions.
> 
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

I don't like these sysfs knobs at all, what are other drivers
doing?
