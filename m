From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] vmxnet3: Register shutdown handler for device (fwd)
Date: Tue, 23 Jun 2015 06:26:59 -0700 (PDT)
Message-ID: <20150623.062659.543712353270550157.davem@davemloft.net>
References: <alpine.DEB.2.02.1506191335180.12845@promg-1n-a-dhcp378.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbbFWNPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:15:09 -0400
In-Reply-To: <alpine.DEB.2.02.1506191335180.12845@promg-1n-a-dhcp378.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All 3 patches applied to net-next.

Next time you submit a series of vmxnet driver patches, number them and
also provide a "[PATCH 0/N] ..." header posting explaining the patch
series and what it is doing as a unit.
