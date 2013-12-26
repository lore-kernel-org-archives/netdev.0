From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/6] bnx2x: new features patch series
Date: Thu, 26 Dec 2013 13:38:53 -0500 (EST)
Message-ID: <20131226.133853.2211726123097632477.davem@davemloft.net>
References: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947Ab3LZSiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:38:54 -0500
In-Reply-To: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Thu, 26 Dec 2013 09:57:06 +0200

> This patch series adds/fixes several new features in the bnx2x driver -
> it adds support for loading the bnx2x over an UNDI running on a Multi-function
> device, adds missing bits for PCIe AER support and enables VFs to properly
> configure multicast filters
> (In addition, it also contains some small improvements in driver behaviour).
> 
> Please consider applying these patches to `net-next'.
> 
> Changes from previous versions
> ------------------------------
>   v2:
>      - Fixed comment typo in patch 4 (propogate --> propagate)

Applied, thanks.
