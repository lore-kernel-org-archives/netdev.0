From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] macsec: enable s/w offloads
Date: Fri, 22 Jul 2016 00:51:08 -0400 (EDT)
Message-ID: <20160722.005108.1493031321755031123.davem@davemloft.net>
References: <cover.1469030596.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net,
	hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbcGVEvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 00:51:13 -0400
In-Reply-To: <cover.1469030596.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 20 Jul 2016 18:11:30 +0200

> This patches leverage gro_cells infrastructure to enable both GRO and RPS
> on macsec devices.
> 
> Paolo Abeni (2):
>   gro_cells: gro_cells_receive now return error code
>   macsec: enable GRO and RPS on macsec devices

Series applied, thanks.
