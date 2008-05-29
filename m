From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bluetooth: fix locking bug in the rfcomm socket
 cleanup handling
Date: Thu, 29 May 2008 01:34:12 -0700 (PDT)
Message-ID: <20080529.013412.180232731.davem@davemloft.net>
References: <20080528213006.02964148@infradead.org>
	<AD9D7FA8-9626-473B-838F-B05ED91742D8@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arjan@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48977
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751119AbYE2IeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 04:34:17 -0400
In-Reply-To: <AD9D7FA8-9626-473B-838F-B05ED91742D8@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 29 May 2008 08:49:53 +0200

> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> 
> David, you might wanna queue this up for stable, too.

Patch applied, and I will queue up for stable, thanks.
