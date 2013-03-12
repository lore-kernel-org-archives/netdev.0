From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/13] bnx2x: patch series
Date: Tue, 12 Mar 2013 07:58:34 -0400 (EDT)
Message-ID: <20130312.075834.2027806082758992323.davem@davemloft.net>
References: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932386Ab3CLL6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 07:58:25 -0400
In-Reply-To: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 11 Mar 2013 17:17:40 +0200

> This patch series contains several changes:
> 
>  1. SR-IOV related patches - allow setting and getting the number of VFs
>     via sysfs, configuring and querying VFs via iproute2 callbacks and
>     properly implement for VFs only the ethtool ops which they can safely
>     perform.
> 
>  2. Advance the FW version used by the driver. This allows 57840 boards to
>     use FCoE, as well as fixing various issues.
> 
>  3. Several small link enhancements.
> 
>  4. Several fixes of rare corner-cases.
> 
> Please consider applying this patch-series to 'net-next'.

Series applied, thanks.
