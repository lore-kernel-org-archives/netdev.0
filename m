From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] __dst_free(): put EXPORT_SYMBOLS after the fct
Date: Tue, 20 Jul 2010 13:28:33 -0700 (PDT)
Message-ID: <20100720.132833.266085623.davem@davemloft.net>
References: <4C4571AA.5060107@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51313
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761496Ab0GTU2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 16:28:17 -0400
In-Reply-To: <4C4571AA.5060107@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 20 Jul 2010 11:51:38 +0200

> this patch is just cosmetic: EXPORT_SYMBOLS(__dst_free) has been put
> after ___dst_free() function instead of __dst_free().

Applied.
