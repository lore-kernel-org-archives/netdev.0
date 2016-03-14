From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] of_mdio: use IS_ERR_OR_NULL() and
 PTR_ERR_OR_ZERO()
Date: Mon, 14 Mar 2016 15:32:21 -0400 (EDT)
Message-ID: <20160314.153221.835659842149162060.davem@davemloft.net>
References: <2682275.WNlbxTfNal@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932608AbcCNTcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:32:24 -0400
In-Reply-To: <2682275.WNlbxTfNal@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 13 Mar 2016 00:32:13 +0300

>    Here's the set of 3 patches against DaveM's 'net-next.git'
> repo. They deal with some error checks in the device tree MDIO
> code...

Series applied, thanks.
