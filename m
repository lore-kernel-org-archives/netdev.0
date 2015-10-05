From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] enic: handle spurious error interrupt
Date: Mon, 05 Oct 2015 03:52:01 -0700 (PDT)
Message-ID: <20151005.035201.1642161930933563773.davem@davemloft.net>
References: <1443689327-15776-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbbJEKgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:36:21 -0400
In-Reply-To: <1443689327-15776-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Thu,  1 Oct 2015 14:18:46 +0530

> Some of the enic adaptors are know to generate spurious interrupts. When
> error interrupt is generated, driver just resets the device. This patch
> resets the device only when an error is occurred.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
