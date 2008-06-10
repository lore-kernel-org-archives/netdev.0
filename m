From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] drivers/atm/eni.h: remove unused macro
 KERNEL_OFFSET
Date: Tue, 10 Jun 2008 12:47:02 -0700 (PDT)
Message-ID: <20080610.124702.121150751.davem@davemloft.net>
References: <200806092331.m59NVxYc014553@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rautelap@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750750AbYFJTrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:47:02 -0400
In-Reply-To: <200806092331.m59NVxYc014553@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 09 Jun 2008 16:31:59 -0700

> KERNEL_OFFSET macro in eni.h is not required as it is not used anywhere. 
> Remove the unused macro from eni.h header file.
> 
> Signed-off-by: Pradeep Singh <rautelap@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
