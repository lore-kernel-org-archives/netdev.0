From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] bnx2x: Enhancement patch series
Date: Thu, 23 May 2013 18:49:51 -0700 (PDT)
Message-ID: <20130523.184951.51052688105215644.davem@davemloft.net>
References: <1369293712-26541-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758618Ab3EXBtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 21:49:52 -0400
In-Reply-To: <1369293712-26541-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 23 May 2013 10:21:48 +0300

> This series contain several small enhancements - chief among those are
> the implementation of ethtool's private flags callback to share information
> about the storage offload capabilities of its network interfaces,
> and the prevention of a link flap when booting from storage area networks.
> 
> Please consider applying these patches to `net-next'.
> 
> Changes from V1:
>   - Patch 1, removed trailing whitespaces from private flag strings.

Series applied, thanks.
