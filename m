From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: add missing parenthesis to prevent u32
 overflow
Date: Wed, 04 Apr 2012 18:04:13 -0400 (EDT)
Message-ID: <20120404.180413.906353392281717189.davem@davemloft.net>
References: <1333542462-22658-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756749Ab2DDWEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:04:16 -0400
In-Reply-To: <1333542462-22658-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 4 Apr 2012 15:27:42 +0300

> From: Dmitry Kravkov <dmitry@broadcom.com>
> 
> Commit b475d78 lacked two pairs of parenthesis, causing an overflow in the
> congestion management.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
