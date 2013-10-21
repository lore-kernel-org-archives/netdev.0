From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/9] bnx2x: Bug fixes patch series
Date: Mon, 21 Oct 2013 18:32:53 -0400 (EDT)
Message-ID: <20131021.183253.1661772228691572834.davem@davemloft.net>
References: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab3JUWcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 18:32:54 -0400
In-Reply-To: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Sun, 20 Oct 2013 16:51:25 +0200

> This patch series contains fixes for various flows - several SR-IOV issues
> are fixed, ethtool callbacks (coalescing and register dump) are corrected,
> null pointer dereference on error flows is prevented, etc.
> 
> Changes from V1
> ---------------
>  - Patch 2  "bnx2x: Prevent an illegal pointer dereference during panic"
>    is revised, with improved handling of edge cases.

Series applied, thanks for strengthening the address validation in
patch #2.
