From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bnxt_en: Bug fixes for net.
Date: Wed, 27 Apr 2016 16:19:04 -0400 (EDT)
Message-ID: <20160427.161904.192374133904523476.davem@davemloft.net>
References: <1461565851-32524-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbcD0UTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 16:19:06 -0400
In-Reply-To: <1461565851-32524-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Mon, 25 Apr 2016 02:30:48 -0400

> Only use MSIX on VF, and fix rx page buffers on architectures with
> PAGE_SIZE >= 64K.

Series applied, thanks Michael.
