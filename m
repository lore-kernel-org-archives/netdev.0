From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bnx2x: Bug patch series
Date: Wed, 01 May 2013 15:08:31 -0400 (EDT)
Message-ID: <20130501.150831.1057046702277707900.davem@davemloft.net>
References: <1367418478-7416-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756120Ab3EATIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:08:34 -0400
In-Reply-To: <1367418478-7416-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 1 May 2013 17:27:56 +0300

> This fixes 2 small bugs - one which may cause an unnecessary link flap,
> and the other is a small memory leak when unloading while cnic is not 
> loaded.

Series applied, thanks.
