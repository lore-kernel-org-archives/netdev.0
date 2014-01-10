From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: prevent WARN during driver unload
Date: Thu, 09 Jan 2014 21:46:26 -0500 (EST)
Message-ID: <20140109.214626.1908262516407859818.davem@davemloft.net>
References: <979A8436335E3744ADCD3A9F2A2B68A52AF23FBC@SJEXCHMB10.corp.ad.broadcom.com>
	<20140108.010140.283557207092663086.davem@davemloft.net>
	<979A8436335E3744ADCD3A9F2A2B68A52AF240A3@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaAJCqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 21:46:31 -0500
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AF240A3@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Wed, 8 Jan 2014 07:05:36 +0000

> True; but we didn't reach this bit of intuitive code on our own -
> this is practically a porting of 27d9ce3f "ixgbe: fix qv_lock_napi
> call in ixgbe_napi_disable_all" into the bnx2x driver.

Fair enough, patch applied, thanks.
